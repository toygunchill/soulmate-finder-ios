//
//  WIYS__Who_is_your_soulmate_App.swift
//  WIYS: Who is your soulmate?
//
//  Created by Toygun Çil on 6.11.2025.
//

import SwiftUI

@main
struct WIYS__Who_is_your_soulmate_App: App {
    @StateObject private var appViewModel = AppViewModel(
        authService: MockAuthService(),
        soulmateService: MockSoulmateService()
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
