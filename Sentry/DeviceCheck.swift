//
//  DeviceCheck.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import CoreGraphics
import Foundation
import SystemConfiguration

enum DeviceCheck {
    static func isMacLocked() -> Bool? {
        let session = CGSessionCopyCurrentDictionary()
        guard let sessionDict = session else { return false }
        let screenLockedKey = "CGSSessionScreenIsLocked" as CFString
        let screenLockedValue = CFDictionaryGetValue(sessionDict, Unmanaged.passUnretained(screenLockedKey).toOpaque())
        if let value = screenLockedValue {
            let isLocked = CFBooleanGetValue(Unmanaged.fromOpaque(value).takeUnretainedValue())
            return isLocked
        }
        let loginDoneKey = "kCGSessionLoginDoneKey" as CFString
        let loginDoneValue = CFDictionaryGetValue(sessionDict, Unmanaged.passUnretained(loginDoneKey).toOpaque())
        if let value = loginDoneValue {
            let isLoginDone = CFBooleanGetValue(Unmanaged.fromOpaque(value).takeUnretainedValue())
            return !isLoginDone
        }
        return nil
    }

    static func isMacLidClosed() -> Bool? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        guard service != 0 else { return false }

        defer { IOObjectRelease(service) }

        let clamshellStateKey = "AppleClamshellState" as CFString
        let clamshellState = IORegistryEntryCreateCFProperty(service, clamshellStateKey, kCFAllocatorDefault, 0)

        if let state = clamshellState?.takeRetainedValue() as? Bool {
            return state
        }

        return nil
    }

    static func isConnectedToWirelessNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
}
