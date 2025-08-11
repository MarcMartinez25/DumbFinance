//
//  AccountsView.swift
//  financefriend
//
//  Created by Margo Martinez on 8/3/25.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    @Query private var accounts: [Account]
    @State private var showingAddAccount = false
    
    var body: some View {
        NavigationView {
            VStack {
                if accounts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Accounts Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Add your first account to get started")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(accounts) { account in
                            AccountRowView(account: account)
                        }
                        .onDelete(perform: deleteAccount)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAccount = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView()
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    
    private func deleteAccount(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(accounts[index])
        }
    }
}

struct AccountRowView: View {
    let account: Account
    
    var body: some View {
        HStack {
            Circle()
                .fill(account.color)
                .frame(width: 12, height: 12)
            
            Image(systemName: account.type.icon)
                .foregroundColor(account.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.headline)
                Text(account.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(account.balance, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(account.balance >= 0 ? .primary : .red)
        }
        .padding(.vertical, 4)
    }
}

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var accountName = ""
    @State private var selectedColor = Color.blue
    @State private var selectedType = AccountType.checking
    @State private var balanceText = ""
    
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
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(!isValidForm)
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(balanceText) != nil
    }
    
    private func saveAccount() {
        guard let balance = Double(balanceText) else { return }
        
        let newAccount = Account(
            name: accountName.trimmingCharacters(in: .whitespacesAndNewlines),
            color: selectedColor,
            type: selectedType,
            balance: balance
        )
        
        modelContext.insert(newAccount)
        dismiss()
    }
}

#Preview {
    AccountsView()
}
