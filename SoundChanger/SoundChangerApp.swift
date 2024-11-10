//
//  SoundChangerApp.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/9.
//

import SwiftUI

@main
struct SoundChangerApp: App {
    @StateObject private var audioManager = AudioManager()
    
    var body: some Scene {
        MenuBarExtra {
            VolumeControlView(audioManager: audioManager)
                .frame(minWidth: 200, idealWidth: 300, maxWidth: 400)
                .padding(.vertical, 4)
            
            
        } label: {
            Image(systemName: "speaker.wave.2.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
