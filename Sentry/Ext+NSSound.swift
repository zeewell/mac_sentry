//
//  Ext+NSSound.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import CoreAudioKit

extension NSSound {
    static func defaultDevice() -> AudioDeviceID {
        var deviceID = AudioObjectID(0)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        var address = AudioObjectPropertyAddress()
        address.mSelector = AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice)
        address.mScope = AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal)
        address.mElement = AudioObjectPropertyElement(kAudioObjectPropertyElementMain)
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID)
        return deviceID
    }

    static func setSystemVolume(_ volume: Float) {
        if volume > 0 {
            var muteVal = 0
            var address = AudioObjectPropertyAddress()
            address.mSelector = AudioObjectPropertySelector(kAudioDevicePropertyMute)
            let size = UInt32(MemoryLayout.size(ofValue: muteVal))
            address.mScope = AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput)
            address.mElement = AudioObjectPropertyElement(kAudioObjectPropertyElementMain)
            AudioObjectSetPropertyData(defaultDevice(), &address, 0, nil, size, &muteVal)
        }
        var volume = volume
        let size = UInt32(MemoryLayout.size(ofValue: volume))
        var address = AudioObjectPropertyAddress()
        address.mScope = AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput)
        address.mElement = AudioObjectPropertyElement(kAudioObjectPropertyElementMain)
        address.mSelector = AudioObjectPropertySelector(kAudioHardwareServiceDeviceProperty_VirtualMainVolume)
        AudioObjectSetPropertyData(defaultDevice(), &address, 0, nil, size, &volume)
    }
}
