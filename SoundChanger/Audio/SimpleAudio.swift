//
//  SimpleAudio.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/10.
//

import CoreAudio
import AVFoundation


class SimpleAudio {
    // 设置当前输出设备
    static func setCurrentDevice(_ deviceID: AudioDeviceID) {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = deviceID
        AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &deviceID
        )
    }
    
    // 获取当前设备名称
    static func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        var propertySize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        // 首先获取属性大小
        var result = AudioObjectGetPropertyDataSize(
            deviceID,
            &address,
            0,
            nil,
            &propertySize
        )
        
        guard result == kAudioHardwareNoError else { return nil }
        
        // 创建一个指向 CFString 的可变指针
        var name: Unmanaged<CFString>?
        
        // 获取设备名称
        result = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &propertySize,
            &name
        )
        
        guard result == kAudioHardwareNoError else { return nil }
        
        // 安全地将 Unmanaged<CFString> 转换为 Swift String
        return name?.takeRetainedValue() as String?
    }
    
    // 获取设备音量
    static func getDeviceVolume(_ deviceID: AudioDeviceID) -> Float {
        var volume: Float = 0
        var propertySize = UInt32(MemoryLayout<Float>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let result = AudioObjectGetPropertyData(deviceID,
                                                &address,
                                                0,
                                                nil,
                                                &propertySize,
                                                &volume)
        
        guard result == kAudioHardwareNoError else { return 0 }
        return volume
    }
    
    // 设置设备音量
    static func setDeviceVolume(deviceID: AudioDeviceID, volume: Float) {
        var newVolume = volume
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectSetPropertyData(deviceID,
                                   &address,
                                   0,
                                   nil,
                                   UInt32(MemoryLayout<Float>.size),
                                   &newVolume)
    }
    
    // 获取当前选中输出设备
    static func getDefaultOutputDevice() -> AudioDeviceID? {
        // For system-level properties like default device, use Global scope
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,  // System-level property
            mElement: kAudioObjectPropertyElementMain
        )
        
        var deviceID: AudioDeviceID = 0
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &deviceID
        )
        
        return status == noErr ? deviceID : nil
    }
    
    // 是否可调节音量
    static func canAdjustVolume(_ deviceID: AudioDeviceID) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        return AudioObjectHasProperty(
            deviceID,
            &propertyAddress
        )
    }
    
    // 获取多设备输出的子设备
    static func getAggregateDeviceSubDeviceList(_ deviceID: AudioDeviceID) -> [AudioDeviceID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioAggregateDevicePropertyActiveSubDeviceList,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var propertySize: UInt32 = 0
        AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &propertySize)
        
        let subDeviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var subDeviceIDs = [AudioDeviceID](repeating: 0, count: subDeviceCount)
        
        AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &propertySize,
            &subDeviceIDs
        )
        return subDeviceIDs
    }
    
    // 获取设备类型
    static func getDeviceType(_ deviceID: AudioDeviceID) -> UInt32 {
        // Get transport type
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyTransportType,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var transportType: UInt32 = 0
        var propertySize = UInt32(MemoryLayout<UInt32>.size)
        
        AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, nil, &propertySize, &transportType)
        return transportType
    }
    
    // 获取输出设备
    static func getOutputDevice() -> [AudioDeviceID] {
        var propertySize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject),
                                       &address,
                                       0,
                                       nil,
                                       &propertySize)
        
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                   &address,
                                   0,
                                   nil,
                                   &propertySize,
                                   &deviceIDs)
        return deviceIDs
    }
}
