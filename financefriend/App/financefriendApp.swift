import SwiftUI
import SwiftData

@main
struct financefriendApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Account.self, Transaction.self])
    }
}
