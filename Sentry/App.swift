//
//  App.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import SwiftUI

struct App: SwiftUI.App {
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    @StateObject var vm = SentryConfigurationManager.shared

    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(timer) { _ in
                    vm.communicateWithSleepHoldServiceIfNeeded()
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}
