//
//  App.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import SwiftUI

struct App: SwiftUI.App {
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commandsRemoved()
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
