//
//  QuickAccessButton.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI

struct QuickAccessButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                            .shadow(color: backgroundColor.opacity(0.5), radius: 5, x: 0, y: 2)
                    )
                
                // Text
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.peg.textPrimary)
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.peg.textSecondary)
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.peg.border.opacity(0.5), lineWidth: 0.5)
            )
            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview
struct QuickAccessButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            QuickAccessButton(
                title: "Redemption History",
                icon: "clock.fill",
                backgroundColor: Color.peg.primaryBlue,
                action: {}
            )
            
            QuickAccessButton(
                title: "My Profile",
                icon: "person.fill",
                backgroundColor: Color.peg.primaryRed,
                action: {}
            )
        }
        .padding()
        .background(Color.peg.background)
        .previewLayout(.sizeThatFits)
    }
}