//
//  OverviewView.swift
//  financefriend
//
//  Created by Margo Martinez on 8/3/25.
//

import SwiftUI

struct OverviewView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Overview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Dashboard coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Overview")
        }
    }
}

#Preview {
    OverviewView()
}
