////
//  PlugCard.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import FirebaseCore
import Combine

struct PlugCard: View {
    let deal: Deal
    let merchant: Merchant?
    let hasActiveRedemption: Bool
    let redemption: Redemption?
    
    @State private var remainingTime: TimeInterval = 0
    @State private var timerCancellable: AnyCancellable?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Deal image
            if !deal.imageUrl.isEmpty {
                AsyncImage(url: URL(string: deal.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.peg.primaryBlue.opacity(0.3))
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            )
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.peg.primaryBlue.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    )
            }
            
            // Deal content
            VStack(alignment: .leading, spacing: 12) {
                // Merchant info
                HStack(spacing: 10) {
                    // Merchant logo or placeholder
                    if let merchant = merchant, !merchant.logo.isEmpty {
                        AsyncImage(url: URL(string: merchant.logo)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.peg.primaryBlue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(merchant.name.prefix(1).uppercased())
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    } else {
                        Circle()
                            .fill(Color.peg.primaryBlue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(merchant?.name.prefix(1).uppercased() ?? "")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(merchant?.name ?? "Unknown Merchant")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.peg.textPrimary)
                        
                        if hasActiveRedemption {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.peg.success)
                                    .frame(width: 8, height: 8)
                                
                                Text("Active")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.peg.success)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Remaining time if active
                    if hasActiveRedemption, let redemption = redemption {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Expires in:")
                                .font(.caption)
                                .foregroundColor(Color.peg.textSecondary)
                            
                            Text(formatTime(remainingTime))
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(remainingTime < 300 ? Color.peg.error : Color.peg.primaryBlue)
                        }
                    }
                }
                
                // Deal title
                Text(deal.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.peg.textPrimary)
                    .lineLimit(2)
                
                // Deal description
                Text(deal.description)
                    .font(.subheadline)
                    .foregroundColor(Color.peg.textSecondary)
                    .lineLimit(3)
                
                // Deal terms - only show if there are terms
                if !deal.terms.isEmpty {
                    Text("Terms: \(deal.terms)")
                        .font(.caption)
                        .foregroundColor(Color.peg.textSecondary.opacity(0.8))
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            if let redemption = redemption {
                updateRemainingTime(redemption: redemption)
                startTimer()
            }
        }
        .onDisappear {
            timerCancellable?.cancel()
        }
    }
    
    // Start timer for active redemption
    private func startTimer() {
        // Cancel existing timer if any
        timerCancellable?.cancel()
        
        // Create and connect a new timer
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if let redemption = redemption {
                    updateRemainingTime(redemption: redemption)
                }
            }
    }
    
    // Update remaining time from redemption
    private func updateRemainingTime(redemption: Redemption) {
        remainingTime = max(0, redemption.remainingTime)
    }
    
    // Format time remaining
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        if timeInterval <= 0 {
            return "Expired"
        }
        
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
struct PlugCard_Previews: PreviewProvider {
    static var previews: some View {
        PlugCard(
            deal: Deal(id: "1", data: [
                "title": "50% off Coffee",
                "description": "Get 50% off any coffee drink. Valid for any size coffee beverage.",
                "terms": "One per customer. Cannot be combined with other offers.",
                "imageUrl": "",
                "merchantId": "merchant1",
                "active": true
            ]),
            merchant: Merchant(id: "merchant1", data: [
                "name": "Coffee Shop",
                "logo": "",
                "active": true
            ]),
            hasActiveRedemption: true,
            redemption: Redemption(id: "redemption1", data: [
                "userId": "user1",
                "dealId": "deal1",
                "merchantId": "merchant1",
                "locationId": "location1",
                "timestamp": Timestamp(date: Date()),
                "validityPeriod": Timestamp(date: Date().addingTimeInterval(600)),
                "status": "pending"
            ])
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Color.peg.background)
    }
}
