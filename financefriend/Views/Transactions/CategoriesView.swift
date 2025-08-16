import SwiftUI

struct CategoriesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Categories")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Transaction categories coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Categories")
        }
    }
}

#Preview {
    CategoriesView()
}
