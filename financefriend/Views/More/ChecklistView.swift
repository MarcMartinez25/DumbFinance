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
