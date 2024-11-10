//
//  ContentView.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/9.
//

import SwiftUI



struct VolumeControlView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(audioManager.outputDevices) { device in
                DeviceVolumeSlider(device: device) { old, new in
                    audioManager.setVolume(deviceID: device.id, lastVolume: old, newVolume: new)
                } onDeivceClick: { id in
                    audioManager.setCurrentDevice(id)
                }
                
            }
            HStack {
                ButtonText(iconName: "arrow.down.square", isSelected: false, text: "check_update") {
                    if let url = URL(string: "https://github.com/achjqz/SoundChanger") {
                        NSWorkspace.shared.open(url)
                    }
                }
                ButtonText(iconName: "xmark", isSelected: false, text: "quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q", modifiers: .command)
            }
            
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        
    }
}

#Preview {
    VolumeControlView(audioManager: AudioManager())
}
