//
//  Slider.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/9.
//

import SwiftUI
import CompactSlider
import CoreAudio

public struct CustomCompactSliderStyle: CompactSliderStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(
                configuration.isHovering || configuration.isDragging
                ? Color(nsColor: .labelColor)
                : Color(nsColor: .secondaryLabelColor)
            )
        // 灰色背景
            .background(
                Color(nsColor: .secondaryLabelColor)
                    .opacity(0.15)
            )
            .compactSliderSecondaryAppearance(
                // 默认进度条 - 白色渐变
                progressShapeStyle: LinearGradient(
                    colors: [
                        Color(nsColor: .white).opacity(0.6),
                        Color(nsColor: .white).opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                // hover/拖动状态 - 更亮的白色渐变
                focusedProgressShapeStyle: LinearGradient(
                    colors: [
                        Color(nsColor: .white).opacity(0.7),
                        Color(nsColor: .white).opacity(0.9)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                // 滑块手柄 - 白色
                handleColor: Color(nsColor: .white),
                // 刻度 - 浅灰色
                scaleColor: Color(nsColor: .tertiaryLabelColor),
                // 次要刻度 - 更浅的灰色
                secondaryScaleColor: Color(nsColor: .quaternaryLabelColor)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

public extension CompactSliderStyle where Self == CustomCompactSliderStyle {
    static var `custom`: CustomCompactSliderStyle { CustomCompactSliderStyle() }
}

struct DeviceVolumeSlider: View {
    let device: AudioDevice
    let onVolumeChange: (Float, Float) -> Void
    let onDeviceClick: (AudioDeviceID)->Void
    
    @State private var volume: Float


    
    init(device: AudioDevice, onVolumeChange: @escaping (Float, Float) -> Void, onDeivceClick: @escaping (AudioDeviceID)->Void) {
        self.device = device
        self.onVolumeChange = onVolumeChange
        self.onDeviceClick = onDeivceClick
        _volume = State(initialValue: device.volume)
        
    }
    
    var body: some View {
        VStack (alignment: .leading){
            ButtonText(iconName: device.deviceType.iconName, isSelected: device.isCurrentDevice, text: device.name, onClick: {
                if !device.isCurrentDevice {
                    onDeviceClick(device.id)
                }
            })
            .frame(maxWidth: .infinity) // 让 HStack 占据整个可用宽度
            CompactSlider(value: $volume,
                          handleVisibility: .hovering(width: 5),
                          scaleVisibility: .hidden) {
                // Volume icon
                Image(systemName: volume == 0 ? "speaker.slash.fill" :
                        volume < 0.1 ? "speaker.fill" :
                        volume < 0.3 ? "speaker.wave.1.fill" :
                        volume < 0.5 ? "speaker.wave.2.fill" : "speaker.wave.3.fill")
                .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 4)
            .onChange(of: volume, { oldValue, newValue in
                if newValue == device.volume {
                    return
                }
                onVolumeChange(oldValue, newValue)
            })
            .onChange(of: device.volume, { _, newValue in
                volume = newValue
            })
            .compactSliderStyle(.custom)
        }
    }
  
}


#Preview {
    DeviceVolumeSlider(device: AudioDevice(id: 1, name: "test", volume: 0.2, isCurrentDevice: false, deviceType: .aggregate)){ old, new in
        
    } onDeivceClick: { id in
        
    }
}
