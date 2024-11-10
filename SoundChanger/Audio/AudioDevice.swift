//
//  AudioDevice.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/9.
//

import SwiftUI
import CoreAudio
import AVFoundation

enum DeviceType {
    case internalSpeaker
    case headphones
    case usb
    case bluetooth
    case airplay
    case hdmi
    case displayPort
    case aggregate
    case airpods
    case unknown
    
    var iconName: String {
        switch self {
        case .internalSpeaker: return "macstudio.fill"
        case .headphones: return "headphones"
        case .usb: return "speaker.wave.2.fill"
        case .bluetooth: return "headphones"
        case .airplay: return "airplayaudio"
        case .hdmi: return "tv"
        case .displayPort: return "display"
        case .aggregate: return "speaker.wave.2.fill"
        case .airpods: return "airpods.pro"
        case .unknown: return "speaker.slash"
        }
    }
    
    var isMultiOutput: Bool {
        return self == .aggregate
    }
}


// MARK: - Audio Device Model
struct AudioDevice: Identifiable {
    let id: AudioDeviceID
    let name: String
    let volume: Float
    let isCurrentDevice: Bool
    let deviceType: DeviceType
}
