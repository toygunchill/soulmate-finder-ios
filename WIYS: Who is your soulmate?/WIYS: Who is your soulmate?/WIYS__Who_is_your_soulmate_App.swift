//
//  WIYS__Who_is_your_soulmate_App.swift
//  WIYS: Who is your soulmate?
//
//  Created by Toygun Çil on 6.11.2025.
//

import SwiftUI

@main
struct WIYS__Who_is_your_soulmate_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
