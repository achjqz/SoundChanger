//
//  ButtonText.swift
//  SoundChanger
//
//  Created by 小小白 on 2024/11/10.
//


import SwiftUI


struct ButtonText: View {
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    let iconName: String
    let isSelected: Bool
    let text: String
    let onClick: ()->Void
    
    var body: some View {
        HStack {
            CircularIconButton(iconName: iconName, isSelected: isSelected)
            Text(LocalizedStringKey(text))
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in
                    isPressed = false
                    onClick()
                }
        )
    }
    private var backgroundColor: Color {
        if isPressed {
            return Color.primary.opacity(0.3)
        } else if isHovered {
            return Color.primary.opacity(0.2)
        }
        return .clear
    }
}

#Preview {
    HStack(spacing: 20) {
        ButtonText(iconName: "heart.fill", isSelected: false, text: "123") {
            
        }
        ButtonText(iconName: "star.fill", isSelected: true, text: "test") {}
        ButtonText(iconName: "heart.fill", isSelected: false, text: "999") {}
    }
    .padding()
}
