import SwiftUI
import SwiftData
import Charts

struct OverviewView: View {
    @Query private var allTransactions: [Transaction]
    @Query private var accounts: [Account]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    MonthlySummaryCard(transactions: currentMonthTransactions)
                    RecentTransactionsCard(transactions: Array(recentTransactions.prefix(4)))
                    AccountsGridCard(accounts: accounts)
                }
                .padding()
            }
            .navigationTitle("Overview")
        }
    }
    
    private var currentMonthTransactions: [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        return allTransactions.filter { txn in
            calendar.isDate(txn.date, equalTo: now, toGranularity: .month) && txn.type != .transfer
        }
    }
    
    private var recentTransactions: [Transaction] {
        allTransactions.sorted { $0.date > $1.date }
    }
}

#Preview {
    OverviewView()
}

private struct MonthlySummaryCard: View {
    let transactions: [Transaction]
    
    private var incomeTotal: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var expenseTotal: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    private var netTotal: Double { incomeTotal - expenseTotal }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Month")
                        .font(.headline)
                    Text(summarySubtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(netLabel)
                        .font(.headline)
                        .foregroundColor(netColor)
                    Text(String(format: "Income: $%.2f", incomeTotal))
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(String(format: "Expenses: $%.2f", expenseTotal))
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if hasData {
                Chart {
                    BarMark(
                        x: .value("Type", "Income"),
                        y: .value("Amount", incomeTotal)
                    )
                    .foregroundStyle(.green)
                    
                    BarMark(
                        x: .value("Type", "Expenses"),
                        y: .value("Amount", expenseTotal)
                    )
                    .foregroundStyle(.red)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .foregroundColor(.secondary)
                    Text("No income or expenses recorded this month")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
    
    private var hasData: Bool { incomeTotal > 0 || expenseTotal > 0 }
    
    private var netLabel: String {
        String(format: "Net: $%.2f", netTotal)
    }
    
    private var netColor: Color { netTotal >= 0 ? .green : .red }
    
    private var summarySubtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: Date())
    }
}

private struct RecentTransactionsCard: View {
    let transactions: [Transaction]
    @State private var showingAddTransaction = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recent Transactions")
                    .font(.headline)
                if !transactions.isEmpty {
                    Text(labelDateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if transactions.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text("No recent transactions")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .padding(.trailing, 32)
                .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                VStack(spacing: 10) {
                    ForEach(transactions) { txn in
                        HStack(spacing: 12) {
                            Image(systemName: iconName(for: txn))
                                .foregroundColor(iconColor(for: txn))
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(txn.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                HStack(spacing: 6) {
                                    if let accountName = accountLabel(for: txn) {
                                        Text(accountName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(shortDate(txn.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text(amountLabel(for: txn))
                                .font(.subheadline)
                                .foregroundColor(amountColor(for: txn))
                        }
                        .padding(.vertical, 4)
                        if txn.id != transactions.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(alignment: .topTrailing) {
            Button(action: { showingAddTransaction = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .padding(10)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
    
    private func iconName(for txn: Transaction) -> String {
        switch txn.type {
        case .expense: return "arrow.down.circle"
        case .income: return "arrow.up.circle"
        case .transfer: return "arrow.left.arrow.right.circle"
        }
    }
    
    private func iconColor(for txn: Transaction) -> Color {
        switch txn.type {
        case .expense: return .red
        case .income: return .green
        case .transfer: return .blue
        }
    }
    
    private func amountLabel(for txn: Transaction) -> String {
        switch txn.type {
        case .expense: return String(format: "-$%.2f", txn.amount)
        case .income: return String(format: "+$%.2f", txn.amount)
        case .transfer: return String(format: "$%.2f", txn.amount)
        }
    }
    
    private func amountColor(for txn: Transaction) -> Color {
        switch txn.type {
        case .expense: return .red
        case .income: return .green
        case .transfer: return .primary
        }
    }
    
    private func shortDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: date)
    }
    
    private var labelDateRange: String {
        guard let first = transactions.first?.date, let last = transactions.last?.date else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: last)) – \(fmt.string(from: first))"
    }
    
    private func accountLabel(for txn: Transaction) -> String? {
        switch txn.type {
        case .expense, .income:
            return txn.account?.name
        case .transfer:
            let from = txn.fromAccount?.name ?? "?"
            let to = txn.toAccount?.name ?? "?"
            return "\(from) → \(to)"
        }
    }
}

private struct AccountsGridCard: View {
    let accounts: [Account]
    @State private var showingAddAccount = false
    @State private var showingEditAccount = false
    @State private var editingAccount: Account? = nil
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddAccount = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            
            if accounts.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "creditcard")
                        .foregroundColor(.secondary)
                    Text("No accounts yet")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(accounts) { account in
                        Button(action: {
                            editingAccount = account
                            showingEditAccount = true
                        }) {
                            HStack(alignment: .center, spacing: 12) {
                                Circle()
                                    .fill(account.color)
                                    .frame(width: 10, height: 10)
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Image(systemName: account.type.icon)
                                            .foregroundColor(account.color)
                                        Text(account.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                    }
                                    Text(String(format: "$%.2f", account.balance))
                                        .font(.footnote)
                                        .foregroundColor(account.balance >= 0 ? .primary : .red)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
        .sheet(isPresented: $showingEditAccount) {
            if let account = editingAccount {
                EditAccountView(account: account)
            }
        }
    }
}

private struct EditAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allTransactions: [Transaction]
    
    let account: Account
    
    @State private var accountName: String = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedType: AccountType = .checking
    @State private var balanceText: String = ""
    @State private var showingDeleteAlert: Bool = false
    
    private let availableColors: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .yellow, .indigo, .mint, .teal
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Account Details") {
                    TextField("Account Name", text: $accountName)
                    Picker("Account Type", selection: $selectedType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    TextField("Current Balance", text: $balanceText)
                        .keyboardType(.decimalPad)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Text("Delete Account")
                    }
                }
            }
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveEdits() }
                        .disabled(!isValidForm)
                }
            }
            .alert("Delete this account?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) { deleteAccount() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove the account and its related transactions. This action cannot be undone.")
            }
            .onAppear(perform: loadInitialValues)
        }
    }
    
    private var isValidForm: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Double(balanceText) != nil
    }
    
    private func loadInitialValues() {
        accountName = account.name
        selectedColor = account.color
        selectedType = account.type
        balanceText = String(format: "%.2f", account.balance)
    }
    
    private func saveEdits() {
        guard let balance = Double(balanceText) else { return }
        account.name = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        account.type = selectedType
        account.color = selectedColor
        account.balance = balance
        dismiss()
    }
    
    private func deleteAccount() {
        // Remove related transactions to avoid dangling references
        for txn in allTransactions {
            if txn.account?.id == account.id || txn.fromAccount?.id == account.id || txn.toAccount?.id == account.id {
                modelContext.delete(txn)
            }
        }
        modelContext.delete(account)
        dismiss()
    }
}
