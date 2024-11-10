//
//  Button.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/10.
//

import SwiftUI


struct CircularIconButton: View {
    let iconName: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // 圆形背景 - 无边框，未选中时为灰色底
            Circle()
                .fill(isSelected ? Color.accentColor : Color(nsColor: .systemGray).opacity(0.3))
                .frame(width: 24, height: 24)
            
            // 图标
            Image(systemName: iconName)
                .foregroundColor(isSelected ? .white : Color(nsColor: .labelColor))
                .font(.system(size: 12))
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        CircularIconButton(iconName: "heart.fill", isSelected: false)
        CircularIconButton(iconName: "star.fill", isSelected: true)
        CircularIconButton(iconName: "heart.fill", isSelected: false)
    }
    .padding()
}
