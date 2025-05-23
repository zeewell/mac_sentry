//
//  SentryConfiguration.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation
import SwiftUI

class SentryConfiguration: ObservableObject {
    static let shared = SentryConfiguration()

    @PublishedPersist(key: "sentry.triggers.lid", defaultValue: false)
    var sentryTriggersLidEnabled: Bool
    @PublishedPersist(key: "sentry.triggers.internet", defaultValue: false)
    var sentryTriggersInternetEnabled: Bool
    @PublishedPersist(key: "sentry.triggers.power", defaultValue: false)
    var sentryTriggersPowerEnabled: Bool

    @PublishedPersist(key: "sentry.alarms.sounds", defaultValue: false)
    var sentryAlarmsSoundsEnabled: Bool
    @PublishedPersist(key: "sentry.alarms.notifications", defaultValue: .none)
    var sentryAlarmsNotificationType: NotificationType

    enum NotificationType: String, Codable, RawRepresentable {
        case none
        case bark
    }

    @PublishedPersist(key: "sentry.notification.config.bark", defaultValue: nil)
    var sentryNotificationConfigBark: NotificationConfiguration_Bark?

    struct NotificationConfiguration_Bark: Codable {
        var endpoint: String = "https://"
        var group: String = .init(localized: "Sentry Notification")
        var icon: String = ""
        var sound: String = "bell"
    }

    private init() {
        print("[*] SentryConfiguration initialized")
    }
}
