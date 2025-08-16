import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ChecklistView()) {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Payday Checklist")
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("Settings")
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    MoreView()
}
