//
//  SentryConfiguration.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation
import SwiftUI

class SentryConfigurationManager: ObservableObject {
    static let shared = SentryConfigurationManager()
    private init() {}

    @PublishedPersist(key: "sentry.config", defaultValue: .init())
    var cfg: SentryConfiguration

    var hasTriggerEnabled: Bool {
        false
            || cfg.sentryTriggersLidEnabled
            || cfg.sentryTriggersInternetEnabled
            || cfg.sentryTriggersPowerEnabled
    }

    var hasNotificationEnabled: Bool {
        false
            || cfg.sentryAlarmsNotificationType != .none
            || cfg.sentryAlarmsSoundsEnabled
    }

    var hasRecordingEnabled: Bool {
        false
            || cfg.sentryRecordingEnabled
    }

    var canActivate: Bool {
        hasTriggerEnabled && hasNotificationEnabled
    }
}

struct SentryConfiguration: Codable, Equatable, Hashable {
    var sentryTriggersLidEnabled: Bool = false
    var sentryTriggersInternetEnabled: Bool = false
    var sentryTriggersPowerEnabled: Bool = false

    var sentryAlarmsSoundsEnabled: Bool = false

    var sentryAlarmsNotificationType: NotificationType = .none
    enum NotificationType: String, Codable, Equatable, Hashable {
        case none
        case bark
    }

    var sentryNotificationConfigBark: NotificationConfiguration_Bark?
    struct NotificationConfiguration_Bark: Codable, Equatable, Hashable {
        var endpoint: String = "https://"
        var group: String = .init(localized: "Sentry Notification")
        var icon: String = ""
        var sound: String = "bell"
    }

    var sentryRecordingEnabled: Bool = false
}
