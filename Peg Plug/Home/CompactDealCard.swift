//
//  CompactDealCard.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI

struct CompactDealCard: View {
    let deal: Deal
    let merchant: Merchant?
    let hasActiveRedemption: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Deal image
                if !deal.imageUrl.isEmpty {
                    AsyncImage(url: URL(string: deal.imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 100)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.peg.primaryBlue.opacity(0.3))
                                .frame(height: 100)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.peg.primaryBlue.opacity(0.3))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        )
                }
                
                // Deal content
                VStack(alignment: .leading, spacing: 8) {
                    // Merchant info
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.peg.primaryBlue)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text(merchant?.name.prefix(1).uppercased() ?? "")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Text(merchant?.name ?? "Unknown Merchant")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(Color.peg.textSecondary)
                            .lineLimit(1)
                    }
                    
                    // Deal title
                    Text(deal.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.peg.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Active tag
                    if hasActiveRedemption {
                        Text("Active")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.peg.success)
                            .cornerRadius(4)
                    }
                }
                .padding(10)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct CompactDealCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                CompactDealCard(
                    deal: Deal(id: "1", data: [
                        "title": "50% off Coffee",
                        "description": "Get 50% off any coffee drink",
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
                    onTap: {}
                )
                .frame(width: 200)
                
                CompactDealCard(
                    deal: Deal(id: "2", data: [
                        "title": "Buy one get one free",
                        "description": "Buy one item, get one free",
                        "imageUrl": "",
                        "merchantId": "merchant2",
                        "active": true
                    ]),
                    merchant: Merchant(id: "merchant2", data: [
                        "name": "Burger Place",
                        "logo": "",
                        "active": true
                    ]),
                    hasActiveRedemption: false,
                    onTap: {}
                )
                .frame(width: 200)
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
        .background(Color.peg.background)
    }
}