//
//  TransactionsView.swift
//  financefriend
//
//  Created by Margo Martinez on 8/3/25.
//

import SwiftUI

struct TransactionsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Transactions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Transaction tracking coming soon...")
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: CategoriesView()) {
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.orange)
                        Text("Manage Categories")
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
            .navigationTitle("Transactions")
        }
    }
}

#Preview {
    TransactionsView()
}
