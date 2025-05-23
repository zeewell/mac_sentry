//
//  AppDelegate.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()
    }

    func applicationDidFinishLaunching(_: Notification) {
        _ = MouseLocation.shared
    }
}
