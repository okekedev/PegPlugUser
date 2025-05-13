//
//  ActivePlugsCard.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/28/25.
//


import SwiftUI
import Combine

struct ActivePlugsCard: View {
    let deals: [DealRedemption]
    let onPlugTap: (String) -> Void
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.peg.primaryBlue)
                    
                    Text("Active Plugs")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color.peg.textPrimary)
                    
                    if !deals.isEmpty {
                        Circle()
                            .fill(Color.peg.primaryBlue)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Text("\(deals.count)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                Spacer()
                
                if !deals.isEmpty {
                    Button(action: onViewAll) {
                        Text("View All")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.peg.primaryBlue)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.peg.primaryBlue.opacity(0.1),
                        Color.peg.primaryBlue.opacity(0.05)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Helper text
            Text(deals.isEmpty ? "Spin to get active deals" : "Show to merchants to redeem")
                .font(.system(size: 12))
                .foregroundColor(Color.peg.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.7))
            
            // Deal list or empty state
            if deals.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "ticket.slash")
                        .font(.system(size: 28))
                        .foregroundColor(Color.peg.primaryBlue.opacity(0.5))
                    
                    Text("No active deals")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.peg.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.white)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(deals) { deal in
                            MiniPlugCard(
                                deal: deal.deal,
                                merchant: deal.merchant,
                                redemption: deal.redemption,
                                onTap: {
                                    onPlugTap(deal.deal.id)
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
                .stroke(Color.peg.primaryBlue.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// DealRedemption struct to combine data
struct DealRedemption: Identifiable {
    let deal: Deal
    let merchant: Merchant?
    let redemption: Redemption
    
    var id: String { deal.id }
}

// Mini Plug Card for horizontal scroll
struct MiniPlugCard: View {
    let deal: Deal
    let merchant: Merchant?
    let redemption: Redemption
    let onTap: () -> Void
    
    @State private var remainingTime: TimeInterval = 0
    @State private var timerCancellable: AnyCancellable?
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                // Top info
                HStack(spacing: 4) {
                    // Merchant initial
                    Circle()
                        .fill(Color.peg.primaryBlue.opacity(0.1))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Text(merchant?.name.prefix(1).uppercased() ?? "")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color.peg.primaryBlue)
                        )
                    
                    // Remaining time
                    Text(formatTime(remainingTime))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(timeColor)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Deal title
                Text(deal.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.peg.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Merchant name
                Text(merchant?.name ?? "")
                    .font(.system(size: 10))
                    .foregroundColor(Color.peg.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 120)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(timeColor.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            updateRemainingTime()
            startTimer()
        }
        .onDisappear {
            timerCancellable?.cancel()
        }
    }
    
    // Time-based color
    private var timeColor: Color {
        if remainingTime <= 300 { // 5 minutes or less
            return Color.peg.error
        } else if remainingTime <= 600 { // 10 minutes or less
            return Color.peg.warning
        } else {
            return Color.peg.success
        }
    }
    
    // Start timer
    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateRemainingTime()
            }
    }
    
    // Update remaining time
    private func updateRemainingTime() {
        remainingTime = max(0, redemption.remainingTime)
    }
    
    // Format time
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval <= 0 {
            return "Expired"
        }
        
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Preview
struct ActivePlugsCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Empty state
            ActivePlugsCard(deals: [], onPlugTap: { _ in }, onViewAll: {})
                .padding()
                .previewLayout(.sizeThatFits)
                .background(Color.peg.background)
            
            // With data
            ActivePlugsCard(
                deals: [
                    DealRedemption(
                        deal: Deal(id: "deal1", data: [
                            "title": "50% off Coffee",
                            "description": "Half off any coffee drink",
                            "merchantId": "m1",
                            "active": true
                        ]),
                        merchant: Merchant(id: "m1", data: [
                            "name": "Coffee Shop",
                            "logo": "",
                            "active": true
                        ]),
                        redemption: Redemption(id: "r1", data: [
                            "userId": "user1",
                            "dealId": "deal1",
                            "merchantId": "m1",
                            "locationId": "loc1",
                            "timestamp": Timestamp(date: Date()),
                            "validityPeriod": Timestamp(date: Date().addingTimeInterval(600)),
                            "status": "pending"
                        ])
                    ),
                    DealRedemption(
                        deal: Deal(id: "deal2", data: [
                            "title": "Free Dessert with Meal",
                            "description": "Get a free dessert with any meal purchase",
                            "merchantId": "m2",
                            "active": true
                        ]),
                        merchant: Merchant(id: "m2", data: [
                            "name": "Burger Place",
                            "logo": "",
                            "active": true
                        ]),
                        redemption: Redemption(id: "r2", data: [
                            "userId": "user1",
                            "dealId": "deal2",
                            "merchantId": "m2",
                            "locationId": "loc2",
                            "timestamp": Timestamp(date: Date()),
                            "validityPeriod": Timestamp(date: Date().addingTimeInterval(1200)),
                            "status": "pending"
                        ])
                    )
                ],
                onPlugTap: { _ in },
                onViewAll: {}
            )
            .padding()
            .previewLayout(.sizeThatFits)
            .background(Color.peg.background)
        }
    }
}