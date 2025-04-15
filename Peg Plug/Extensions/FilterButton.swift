//
//  FilterButton.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/24/25.
//


//
//  FilterButton.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/17/25.
//

import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.peg.primaryRed : Color.peg.fieldBackground) // Updated from theme
                .foregroundColor(isSelected ? .white : Color.peg.textPrimary) // Updated from theme
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.peg.border, lineWidth: isSelected ? 0 : 1) // Updated from theme
                )
                .shadow(color: isSelected ? Color.peg.shadow.opacity(0.3) : Color.clear, radius: 3, x: 0, y: 2) // Added subtle shadow
        }
    }
}

// MARK: - Preview
struct FilterButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background for better visibility
            Color.peg.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Selected filter
                FilterButton(
                    title: "All Deals",
                    isSelected: true,
                    action: {}
                )
                
                // Unselected filter
                FilterButton(
                    title: "Nearby",
                    isSelected: false,
                    action: {}
                )
                
                // Row of filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All", isSelected: true, action: {})
                        FilterButton(title: "Coffee", isSelected: false, action: {})
                        FilterButton(title: "Restaurants", isSelected: false, action: {})
                        FilterButton(title: "Retail", isSelected: false, action: {})
                    }
                    .padding(.horizontal)
                }
                .frame(height: 50)
            }
            .padding()
        }
    }
}