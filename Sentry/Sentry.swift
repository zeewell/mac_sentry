//
//  Sentry.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import AppKit
import AVFAudio
import AVKit
import Foundation
import SkyLightWindow
import SwiftUI

class Sentry {
    let configuration: SentryConfiguration
    let onAlarmingActivaty: (_ reason: String) -> Void

    init(configuration: SentryConfiguration, onAlarmingActivaty: @escaping (_ reason: String) -> Void) {
        self.configuration = configuration
        self.onAlarmingActivaty = onAlarmingActivaty
    }

    private var lastLidState: Bool?
    private var lastNetworkState: Bool?
    private var lastPowerState: Bool?

    private var isCurrentlyAlarming: Bool = false

    enum Status {
        case run
        case tearingDown
        case stop
    }

    private var status: Status = .stop
    private var windowController: NSWindowController?

    func run() {
        assert(status == .stop, "Sentry is already running")
        status = .run
        assert(Thread.isMainThread)
        windowController = SkyLightOperator.shared.delegateView(
            AnyView(SentryView()),
            toScreen: .main!
        )
        if configuration.sentryRecordingEnabled {
            startRecording()
        }
        Thread {
            while self.status == .run {
                sleep(1)
                self.executeOnce()
            }
        }
        .start()
    }

    // stop the monitor & on going alarms
    func stop() {
        guard status == .run else { return }
        status = .tearingDown
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            windowController?.window?.contentView?.animator().alphaValue = 0
        } completionHandler: {
            self.windowController?.close()
            self.status = .stop
            self.resetStates()
        }
    }

    private func resetStates() {
        lastLidState = nil
        lastNetworkState = nil
        lastPowerState = nil
        isCurrentlyAlarming = false
    }

    private func executeOnce() {
        guard !isCurrentlyAlarming else { return }

        if configuration.sentryTriggersLidEnabled {
            checkLidState()
        }
        if configuration.sentryTriggersInternetEnabled {
            checkNetworkState()
        }
        if configuration.sentryTriggersPowerEnabled {
            checkPowerState()
        }
    }

    private func checkLidState() {
        guard let currentLidState = DeviceCheck.isMacLidClosed() else { return }

        if lastLidState == nil {
            lastLidState = currentLidState
            return
        }

        if let lastState = lastLidState, !lastState, currentLidState {
            triggerAlarm(reason: String(localized: "Mac Lid Closed"))
        }

        lastLidState = currentLidState
    }

    private func checkNetworkState() {
        let currentNetworkState = DeviceCheck.isConnectedToWirelessNetwork()

        if lastNetworkState == nil {
            lastNetworkState = currentNetworkState
            return
        }

        if let lastState = lastNetworkState, lastState, !currentNetworkState {
            triggerAlarm(reason: String(localized: "Network Disconnected"))
        }

        lastNetworkState = currentNetworkState
    }

    private func checkPowerState() {
        let currentPowerState = DeviceCheck.isConnectedToPower()

        if lastPowerState == nil {
            lastPowerState = currentPowerState
            return
        }

        if let lastState = lastPowerState, lastState, !currentPowerState {
            triggerAlarm(reason: String(localized: "Power Disconnected"))
        }

        lastPowerState = currentPowerState
    }

    private func triggerAlarm(reason: String) {
        guard !isCurrentlyAlarming else { return }
        isCurrentlyAlarming = true
        DispatchQueue.main.async {
            self.onAlarmingActivaty(reason)
        }
        executeAlarmActions(reason: reason)
    }

    private func executeAlarmActions(reason: String) {
        if configuration.sentryAlarmsSoundsEnabled {
            playAlarmSound()
        }

        switch configuration.sentryAlarmsNotificationType {
        case .bark:
            sendBarkNotification(message: reason)
        case .none:
            break
        }
    }

    private func playAlarmSound() {
        while status == .run, isCurrentlyAlarming {}
    }

    private func sendBarkNotification(message _: String) {}

    private func startRecording() {
        print("开始录制...")
    }
}
