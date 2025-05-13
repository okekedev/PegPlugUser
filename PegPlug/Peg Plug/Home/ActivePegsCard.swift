//
//  ActivePegsCard.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/28/25.
//


import SwiftUI

struct ActivePegsCard: View {
    let locations: [LocationWithMerchant]
    let onPegTap: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.peg.primaryRed)
                    
                    Text("Active Pegs")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.peg.textPrimary)
                    
                    if !locations.isEmpty {
                        Circle()
                            .fill(Color.peg.primaryRed)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Text("\(locations.count)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.peg.primaryRed.opacity(0.1),
                        Color.peg.primaryRed.opacity(0.05)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Helper text
            Text(locations.isEmpty ? "Visit locations to activate" : "Tap to spin for deals")
                .font(.system(size: 12))
                .foregroundColor(Color.peg.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.7))
            
            // Peg list or empty state
            if locations.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 28))
                        .foregroundColor(Color.peg.primaryRed.opacity(0.5))
                    
                    Text("No active pegs")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.peg.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.white)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(locations) { pegItem in
                            MiniPegCard(
                                location: pegItem.location,
                                merchant: pegItem.merchant,
                                onTap: {
                                    onPegTap(pegItem.location.id, pegItem.merchant.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .frame(height: 100)
                .background(Color.white)
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.peg.primaryRed.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Mini Peg Card for horizontal scroll
struct MiniPegCard: View {
    let location: Location
    let merchant: Merchant
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                // Logo/Icon
                ZStack {
                    Circle()
                        .fill(Color.peg.primaryRed.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text(merchant.name.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.peg.primaryRed)
                }
                
                // Location name (truncated)
                Text(location.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.peg.textPrimary)
                    .lineLimit(1)
                    .frame(width: 70)
                
                // Merchant name (truncated)
                Text(merchant.name)
                    .font(.system(size: 10))
                    .foregroundColor(Color.peg.textSecondary)
                    .lineLimit(1)
                    .frame(width: 70)
            }
            .frame(width: 80)
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.peg.primaryRed.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview
struct ActivePegsCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Empty state
            ActivePegsCard(locations: [], onPegTap: { _, _ in })
                .padding()
                .previewLayout(.sizeThatFits)
                .background(Color.peg.background)
            
            // With data
            ActivePegsCard(
                locations: [
                    LocationWithMerchant(
                        location: Location(id: "loc1", data: [
                            "name": "Downtown",
                            "address": "123 Main St",
                            "merchantId": "m1"
                        ]),
                        merchant: Merchant(id: "m1", data: [
                            "name": "Coffee Shop",
                            "logo": "",
                            "active": true
                        ])
                    ),
                    LocationWithMerchant(
                        location: Location(id: "loc2", data: [
                            "name": "Uptown",
                            "address": "456 Market St",
                            "merchantId": "m2"
                        ]),
                        merchant: Merchant(id: "m2", data: [
                            "name": "Bakery",
                            "logo": "",
                            "active": true
                        ])
                    )
                ],
                onPegTap: { _, _ in }
            )
            .padding()
            .previewLayout(.sizeThatFits)
            .background(Color.peg.background)
        }
    }
}