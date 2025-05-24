//
//  AppDelegate.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import Cocoa
import Foundation
import IOKit
import IOKit.pwr_mgt
import SwiftUI

class AppDelegate: NSObject, ObservableObject, NSApplicationDelegate {
    private var sleepAssertionID: IOPMAssertionID = 0
    private var displayAssertionID: IOPMAssertionID = 0

    override init() {
        super.init()
        print("[*] AppDelegate initialized")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationDidFinishLaunching(_: Notification) {
        _ = MouseLocation.shared
        preventSleep()
        preventDisplaySleep()
        if let isClamshellClosed = DeviceCheck.isMacLidClosed() {
            print("[*] device check reporting clamshell closed: \(isClamshellClosed)")
        } else {
            print("[*] failed to get clamshell state")
            presentError(title: "Sentry", message: "Unable to configure Sentry. Please try again later.")
        }
        if let isLocked = DeviceCheck.isMacLocked() {
            print("[*] device check reporting screen locked: \(isLocked)")
        } else {
            print("[*] failed to get screen lock state")
            presentError(title: "Sentry", message: "Unable to configure Sentry. Please try again later.")
        }
        let wifi = DeviceCheck.isConnectedToWirelessNetwork()
        print("[*] device check reporting wifi connected: \(wifi)")
        let power = DeviceCheck.isConnectedToPower()
        print("[*] device check reporting power connected: \(power)")
        if let battery = DeviceCheck.getBatteryLevel() {
            print("[*] device check reporting battery level: \(battery)")
        } else {
            print("[*] failed to get battery level")
            presentError(title: "Sentry", message: "Unable to configure Sentry. Please try again later.")
        }
    }

    func applicationWillTerminate(_: Notification) {
        allowSleep()
        allowDisplaySleep()
    }

    private func preventSleep() {
        let reason = "Sentry app is monitoring system" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoIdleSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &sleepAssertionID
        )

        if result != kIOReturnSuccess {
            print("[*] failed to create sleep assertion: \(result)")
            presentError(title: "Sentry", message: "Unable to configure Sentry. Please try again later.")
        }
    }

    private func allowSleep() {
        if sleepAssertionID != 0 {
            IOPMAssertionRelease(sleepAssertionID)
            sleepAssertionID = 0
        }
    }

    private func preventDisplaySleep() {
        let reason = "Sentry app is monitoring display" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &displayAssertionID
        )

        if result != kIOReturnSuccess {
            print("[*] failed to create display assertion: \(result)")
            presentError(title: "Sentry", message: "Unable to configure Sentry. Please try again later.")
        }
    }

    private func allowDisplaySleep() {
        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }
    }

    private func presentError(title: String.LocalizationValue, message: String.LocalizationValue) {
        let alert = NSAlert()
        alert.messageText = String(localized: title)
        alert.informativeText = String(localized: message)
        alert.alertStyle = .critical
        alert.addButton(withTitle: String(localized: "OK"))
        alert.runModal()
    }
}
