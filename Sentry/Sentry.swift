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
        windowController?.close()
    }

    private func executeOnce() {}
}
