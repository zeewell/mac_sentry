//
//  DeviceCheck.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation
import CoreGraphics

/*
 [*] clamshell closed: true
 [*] screen locked: true
 
 verified!
 */

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
}
