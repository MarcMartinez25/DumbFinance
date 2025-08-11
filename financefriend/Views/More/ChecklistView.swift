//
//  ChecklistView.swift
//  financefriend
//
//  Created by Margo Martinez on 8/3/25.
//

import SwiftUI

struct ChecklistView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Payday Checklist")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Payday checklist coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Checklist")
        }
    }
}

#Preview {
    ChecklistView()
}
