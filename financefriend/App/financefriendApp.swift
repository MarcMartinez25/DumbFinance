//
//  financefriendApp.swift
//  financefriend
//
//  Created by Margo Martinez on 8/3/25.
//

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
