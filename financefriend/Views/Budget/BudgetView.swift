import SwiftUI

struct BudgetView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Budget")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Budget tracking coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Budget")
        }
    }
}

#Preview {
    BudgetView()
}
