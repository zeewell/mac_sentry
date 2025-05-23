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
    // MARK: - Configuration & Callbacks

    let configuration: SentryConfiguration
    let onAlarmingActivaty: (_ reason: String) -> Void

    // MARK: - Status Management

    enum Status {
        case run
        case tearingDown
        case stop
    }

    private var status: Status = .stop
    private var windowController: NSWindowController?

    // MARK: - Device State Tracking

    private var lastLidState: Bool?
    private var lastNetworkState: Bool?
    private var lastPowerState: Bool?

    // MARK: - Alarm System

    private var isCurrentlyAlarming: Bool = false
    private var audioPlayer: AVAudioPlayer?
    private var volumeTimer: Timer?

    // MARK: - Initialization

    init(configuration: SentryConfiguration, onAlarmingActivaty: @escaping (_ reason: String) -> Void) {
        self.configuration = configuration
        self.onAlarmingActivaty = onAlarmingActivaty
    }

    // MARK: - Public Methods

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

    func stop() {
        guard status == .run else { return }
        status = .tearingDown
        unlockAlarm()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            windowController?.window?.contentView?.animator().alphaValue = 0
        } completionHandler: {
            self.windowController?.close()
            self.status = .stop
            self.resetStates()
        }
    }

    func unlockAlarm() {
        guard isCurrentlyAlarming else { return }
        isCurrentlyAlarming = false
        stopAlarm()
    }

    // MARK: - Private Methods - State Management

    private func resetStates() {
        lastLidState = nil
        lastNetworkState = nil
        lastPowerState = nil
        isCurrentlyAlarming = false
        stopAlarm()
    }

    // MARK: - Private Methods - Monitoring

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

    // MARK: - Private Methods - Alarm System

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
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("找不到 alarm.mp3 文件")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // 无限循环
            audioPlayer?.volume = 0.1 // 开始时 10% 音量
            audioPlayer?.play()

            // 启动音量渐增定时器
            startVolumeTimer()
        } catch {
            print("播放音频失败: \(error)")
        }
    }

    private func startVolumeTimer() {
        volumeTimer?.invalidate()
        var currentStep = 0
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self, isCurrentlyAlarming else {
                timer.invalidate()
                return
            }

            currentStep += 1
            if currentStep <= 3 {
                // 前3秒保持 10% 音量
                return
            }

            // 从第4秒开始每秒递增 20%
            let newVolume = min(1.0, 0.1 + Float(currentStep - 3) * 0.2)
            audioPlayer?.volume = newVolume

            if newVolume >= 1.0 {
                timer.invalidate()
            }
        }
    }

    private func stopAlarm() {
        volumeTimer?.invalidate()
        volumeTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Private Methods - Notifications

    private func sendBarkNotification(message: String) {
        guard configuration.sentryAlarmsNotificationType == .bark else { return }
        guard let initialURL = URL(string: configuration.sentryNotificationConfigBark.endpoint) else {
            return
        }
        let newURL = initialURL
            .appendingPathComponent(String(localized: "Sentry Mode - Mac"))
            .appendingPathComponent(message)
        guard var comps = URLComponents(url: newURL, resolvingAgainstBaseURL: false) else { return }
        comps.queryItems = [
            .init(name: "level", value: "critical"),
            .init(name: "volume", value: "5"),
            .init(name: "group", value: String(localized: "Sentry Mode - Mac")),
            .init(name: "isArchive", value: "1"),
            .init(name: "call", value: "1"),
        ]
        let url = comps.url
        guard let url = url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[*] bark push error: \(error)")
            }
        }.resume()
    }

    // MARK: - Private Methods - Recording

    private func startRecording() {
        print("[*] start recording camera...")
        
        
    }
}
