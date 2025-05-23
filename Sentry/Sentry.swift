//
//  Sentry.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation

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

    func run() {
        assert(status == .stop, "Sentry is already running")
        status = .run
        Thread {
            while self.status == .run {
                sleep(1)
                self.executeOnce()
            }
        }
        .start()
    }

    func stop() {
        assert(status == .run, "Sentry is not running")
        status = .tearingDown
    }

    private func executeOnce() {}
}
