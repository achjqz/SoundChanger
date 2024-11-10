//
//  AudioManager.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/9.
//

import SwiftUI
import CoreAudio
import AVFoundation

// MARK: - Audio Manager
class AudioManager: ObservableObject {
    @Published var outputDevices: [AudioDevice] = []
    private var propertyListeners: [AudioObjectPropertyListenerBlock] = []
    
    init() {
        updateDeviceList()
        addDevicesListener()
    }
    
    deinit {
        propertyListeners.removeAll()
    }
    
    
    func setCurrentDevice(_ deviceID: AudioDeviceID) {
        SimpleAudio.setCurrentDevice(deviceID)
    }
    
    private func addDevicesListener() {
        // 监听设备列表变化
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let listener: AudioObjectPropertyListenerBlock = { [weak self] (inNumberAddresses, inAddresses) in
            self?.updateDeviceList()
        }
        
        propertyListeners.append(listener) // 保持引用
        
        let status = AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            nil,
            listener
        )
        
        if status != noErr {
            print("Error setting up device listener: \(status)")
        }
        
        // 监听默认输出设备变化
        address.mSelector = kAudioHardwarePropertyDefaultOutputDevice
        
        let defaultDeviceListener: AudioObjectPropertyListenerBlock = { [weak self] (inNumberAddresses, inAddresses) in
            self?.updateDeviceList()
        }
        
        propertyListeners.append(defaultDeviceListener)
        
        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            nil,
            defaultDeviceListener
        )
    }
    
    func updateDeviceList() {
        let deviceIDs = SimpleAudio.getOutputDevice()
        let curDeivceID = SimpleAudio.getDefaultOutputDevice()
        let validOutputDevices = deviceIDs.compactMap { deviceID -> AudioDevice? in
            guard let name = SimpleAudio.getDeviceName(deviceID),
                  SimpleAudio.canAdjustVolume(deviceID) else { return nil }
            return AudioDevice(
                id: deviceID,
                name: name,
                volume: SimpleAudio.getDeviceVolume(deviceID),
                isCurrentDevice: curDeivceID == deviceID,
                deviceType: getDeviceType(deviceID, name)
            )
        }
        let deviceDict = Dictionary(uniqueKeysWithValues: validOutputDevices.map { ($0.id, $0) })
        let multiOutputDevices = deviceIDs.compactMap { deviceID -> AudioDevice? in
            guard let name = SimpleAudio.getDeviceName(deviceID) else { return nil }
            let deviceType = getDeviceType(deviceID, name)
            guard deviceType.isMultiOutput else {
                return nil
            }
            let subDeviceIDs =  SimpleAudio.getAggregateDeviceSubDeviceList(deviceID)
            // Use compactMap to find valid sub-devices and reduce to calculate the sum of volumes
            let validSubDevices = subDeviceIDs.compactMap { deviceDict[$0] }
            var volume: Float = 0.0
            if !validSubDevices.isEmpty {
                let totalVolume = validSubDevices.reduce(0.0) { $0 + $1.volume }
                volume = totalVolume / Float(validSubDevices.count)
            }
            return AudioDevice(
                id: deviceID,
                name: name,
                volume: volume,
                isCurrentDevice: curDeivceID == deviceID,
                deviceType: deviceType
            )
        }
        DispatchQueue.main.async { [weak self] in
            self?.outputDevices = validOutputDevices + multiOutputDevices
        }
    }
    
    
    
    func setVolume(deviceID: AudioDeviceID, lastVolume: Float, newVolume: Float) {
        // Get the device once at the beginning
        guard let device = outputDevices.first(where: { $0.id == deviceID }) else {
            return
        }
        
        // Check if the device is multi-output
        if device.deviceType.isMultiOutput {
            let subDeviceIDs =  SimpleAudio.getAggregateDeviceSubDeviceList( deviceID)
            
            // Loop through sub-devices
            for did in subDeviceIDs {
                // Retrieve the sub-device for the current ID
                guard let subDevice = outputDevices.first(where: { $0.id == did }) else {
                    continue
                }
                
                var newSubDeviceVolume = subDevice.volume + newVolume - lastVolume
                newSubDeviceVolume = max(0, min(1, newSubDeviceVolume))
                
                // Set the new volume for the sub-device
                SimpleAudio.setDeviceVolume(deviceID: did, volume: newSubDeviceVolume)
            }
        } else {
            // For a non-multi-output device, set the volume directly
            SimpleAudio.setDeviceVolume(deviceID: deviceID, volume: newVolume)
        }
        
        // Update the device list
        updateDeviceList()
    }
    
    
    func getDeviceType(_ deviceID: AudioDeviceID, _ name: String) -> DeviceType {
        
        let transportType = SimpleAudio.getDeviceType(deviceID)
        
        // Determine device type based on transport type and name
        switch transportType {
        case kAudioDeviceTransportTypeBuiltIn:
            return name.lowercased().contains("mac")  ? .internalSpeaker : .headphones
            
        case kAudioDeviceTransportTypeUSB:
            return .usb
            
        case kAudioDeviceTransportTypeBluetooth:
            return name.lowercased().contains("airpods") ? .airpods:.bluetooth
            
        case kAudioDeviceTransportTypeHDMI:
            return .hdmi
            
        case kAudioDeviceTransportTypeDisplayPort:
            return .displayPort
            
        case kAudioDeviceTransportTypeAirPlay:
            return .airplay
        case kAudioDeviceTransportTypeAggregate:
            return .aggregate
        default:
            return .unknown
        }
    }
    
}
