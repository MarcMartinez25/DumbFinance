import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var showingAddTransaction = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            Group {
                if transactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Transactions Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add your first transaction to get started")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(transactions) { txn in
                            TransactionRowView(transaction: txn)
                        }
                        .onDelete(perform: deleteTransaction)
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
        }
    }

    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let txn = transactions[index]
            switch txn.type {
            case .expense:
                txn.account?.balance += txn.amount
            case .income:
                txn.account?.balance -= txn.amount
            case .transfer:
                txn.fromAccount?.balance += txn.amount
                txn.toAccount?.balance -= txn.amount
            }
            modelContext.delete(txn)
        }
    }
}

#Preview {
    TransactionsView()
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.headline)
                if let details = transaction.details, !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(dateString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(amountString)
                .font(.headline)
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 4)
    }
    
    private var amountString: String {
        switch transaction.type {
        case .expense:
            return String(format: "-$%.2f", transaction.amount)
        case .income:
            return String(format: "+$%.2f", transaction.amount)
        case .transfer:
            return String(format: "$%.2f", transaction.amount)
        }
    }
    
    private var amountColor: Color {
        switch transaction.type {
        case .expense: return .red
        case .income: return .green
        case .transfer: return .primary
        }
    }
    
    private var iconName: String {
        switch transaction.type {
        case .expense: return "arrow.down.circle"
        case .income: return "arrow.up.circle"
        case .transfer: return "arrow.left.arrow.right.circle"
        }
    }
    
    private var iconColor: Color {
        switch transaction.type {
        case .expense: return .red
        case .income: return .green
        case .transfer: return .blue
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: transaction.date)
    }
}

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var accounts: [Account]
    
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var amountText: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedAccount: Account?
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    @State private var customDate: Date? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $details)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    if selectedType == .transfer && transferExceedsBalance {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Amount exceeds available balance in source account")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    if let boundDate = customDate {
                        DatePicker(
                            "Date",
                            selection: Binding(
                                get: { boundDate },
                                set: { customDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        Button("Clear Date") { customDate = nil }
                            .foregroundColor(.red)
                    } else {
                        Button("Set Date") { customDate = .now }
                        Text("No date set. Will use today's date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Account")) {
                    if selectedType == .transfer {
                        Picker("From", selection: $fromAccount) {
                            Text("Select account").tag(Optional<Account>(nil))
                            ForEach(accounts) { acc in
                                Text(acc.name).tag(Optional(acc))
                            }
                        }
                        Picker("To", selection: $toAccount) {
                            Text("Select account").tag(Optional<Account>(nil))
                            ForEach(accounts) { acc in
                                Text(acc.name).tag(Optional(acc))
                            }
                        }
                    } else {
                        Picker("Account", selection: $selectedAccount) {
                            Text("Select account").tag(Optional<Account>(nil))
                            ForEach(accounts) { acc in
                                Text(acc.name).tag(Optional(acc))
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTransaction() }
                        .disabled(!isValid)
                }
            }
        }
        .onAppear {
            if selectedAccount == nil {
                selectedAccount = accounts.first
            }
            if fromAccount == nil { fromAccount = accounts.first }
        }
    }
    
    private var isValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, let amount = Double(amountText) else { return false }
        switch selectedType {
        case .expense, .income:
            return selectedAccount != nil
        case .transfer:
            guard let from = fromAccount, let to = toAccount, from.id != to.id else { return false }
            return amount <= from.balance
        }
    }
    
    private var transferExceedsBalance: Bool {
        guard selectedType == .transfer, let from = fromAccount, let amount = Double(amountText) else { return false }
        return amount > from.balance
    }
    
    private func saveTransaction() {
        guard let amount = Double(amountText) else { return }
        let finalDate = customDate ?? .now
        
        switch selectedType {
        case .expense:
            guard let acc = selectedAccount else { return }
            let txn = Transaction(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                details: details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : details,
                amount: amount,
                date: finalDate,
                type: .expense,
                account: acc
            )
            modelContext.insert(txn)
            acc.balance -= amount
        case .income:
            guard let acc = selectedAccount else { return }
            let txn = Transaction(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                details: details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : details,
                amount: amount,
                date: finalDate,
                type: .income,
                account: acc
            )
            modelContext.insert(txn)
            acc.balance += amount
        case .transfer:
            guard let from = fromAccount, let to = toAccount, from.id != to.id else { return }
            guard amount <= from.balance else { return }
            let txn = Transaction(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                details: details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : details,
                amount: amount,
                date: finalDate,
                type: .transfer,
                fromAccount: from,
                toAccount: to
            )
            modelContext.insert(txn)
            from.balance -= amount
            to.balance += amount
        }
        dismiss()
    }
}
