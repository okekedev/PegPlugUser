//
//  DealDetailView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


//
//  DealDetailView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import CoreLocation

struct DealDetailView: View {
    let deal: Deal
    @StateObject private var viewModel: DealDetailViewModel
    @ObservedObject private var locationManager = LocationManager.shared
    
    init(deal: Deal) {
        self.deal = deal
        self._viewModel = StateObject(wrappedValue: DealDetailViewModel(deal: deal))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Deal Image
                if !deal.imageUrl.isEmpty {
                    AsyncImage(url: URL(string: deal.imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        } else {
                            // Placeholder
                            Rectangle()
                                .fill(Color.peg.primaryBlue.opacity(0.3))
                                .frame(height: 250)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                } else {
                    // Placeholder
                    Rectangle()
                        .fill(Color.peg.primaryBlue.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Merchant info
                    if let merchant = viewModel.merchant {
                        HStack(spacing: 16) {
                            // Merchant Logo
                            if !merchant.logo.isEmpty {
                                AsyncImage(url: URL(string: merchant.logo)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    } else {
                                        CirclePlaceholder(text: merchant.name.prefix(1).uppercased())
                                    }
                                }
                            } else {
                                CirclePlaceholder(text: merchant.name.prefix(1).uppercased())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(merchant.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.peg.textPrimary)
                                
                                if let closestLocation = viewModel.closestLocation {
                                    Text(closestLocation.name)
                                        .font(.subheadline)
                                        .foregroundColor(Color.peg.textSecondary)
                                }
                                
                                // Distance indicator
                                if let userLocation = locationManager.userLocation,
                                   let closestLocation = viewModel.closestLocation {
                                    let locationCoordinate = CLLocation(
                                        latitude: closestLocation.coordinate.latitude,
                                        longitude: closestLocation.coordinate.longitude
                                    )
                                    
                                    let distance = userLocation.distance(from: locationCoordinate)
                                    let distanceInMiles = distance / 1609.34 // Convert meters to miles
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.peg.primaryRed)
                                        
                                        Text(String(format: "%.1f miles away", distanceInMiles))
                                            .font(.caption)
                                            .foregroundColor(Color.peg.textSecondary)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // Deal title
                    Text(deal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.peg.textPrimary)
                        .padding(.horizontal)
                    
                    // Deal description
                    Text(deal.description)
                        .font(.body)
                        .foregroundColor(Color.peg.textPrimary)
                        .padding(.horizontal)
                    
                    // Terms if available
                    if !deal.terms.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Terms and Conditions")
                                .font(.headline)
                                .foregroundColor(Color.peg.textPrimary)
                            
                            Text(deal.terms)
                                .font(.subheadline)
                                .foregroundColor(Color.peg.textSecondary)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    // Redemption status indicator
                    if viewModel.activeRedemption != nil {
                        ActiveRedemptionCard(redemption: viewModel.activeRedemption!)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                    
                    // Location section
                    if !viewModel.locations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Available Locations")
                                .font(.headline)
                                .foregroundColor(Color.peg.textPrimary)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.locations, id: \.id) { location in
                                LocationListItem(
                                    location: location,
                                    isClosest: location.id == viewModel.closestLocation?.id
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    
                    Spacer()
                }
                
                // Redeem button
                if viewModel.activeRedemption == nil {
                    Button(action: {
                        viewModel.redeemDeal(userLocation: locationManager.userLocation)
                    }) {
                        HStack {
                            Spacer()
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(viewModel.canRedeem ? "Redeem Now" : "Must Be At Location To Redeem")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(viewModel.canRedeem ? Color.peg.primaryRed : Color.gray)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .disabled(!viewModel.canRedeem || viewModel.isLoading)
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(Color.peg.error)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                } else {
                    // View active redemption button
                    NavigationLink(destination: RedemptionView(
                        redemption: viewModel.activeRedemption!,
                        deal: deal,
                        merchant: viewModel.merchant,
                        location: viewModel.locations.first(where: { $0.id == viewModel.activeRedemption!.locationId })
                    )) {
                        HStack {
                            Spacer()
                            
                            Text("View Active Redemption")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(Color.peg.success)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(Color.peg.background)
        .navigationTitle("Deal Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadMerchantAndLocations()
            viewModel.checkForActiveRedemption()
            viewModel.checkIfUserInRange(userLocation: locationManager.userLocation)
        }
        .onChange(of: locationManager.userLocation) { newLocation in
            viewModel.checkIfUserInRange(userLocation: newLocation)
        }
    }
}

// Helper views

struct CirclePlaceholder: View {
    let text: String
    
    var body: some View {
        Circle()
            .fill(Color.peg.primaryBlue)
            .frame(width: 60, height: 60)
            .overlay(
                Text(text)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

struct LocationListItem: View {
    let location: Location
    let isClosest: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.peg.textPrimary)
                
                Text(location.address)
                    .font(.caption)
                    .foregroundColor(Color.peg.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isClosest {
                Text("Closest")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.peg.primaryRed)
                    .cornerRadius(8)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color.peg.textSecondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ActiveRedemptionCard: View {
    let redemption: Redemption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.peg.success)
                    .font(.system(size: 20))
                
                Text("Active Redemption")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.peg.success)
                
                Spacer()
                
                Text(formatExpiryTime(redemption.validityPeriod))
                    .font(.subheadline)
                    .foregroundColor(Color.peg.textSecondary)
            }
            
            Text("You have already redeemed this deal. You can view your active redemption.")
                .font(.subheadline)
                .foregroundColor(Color.peg.textSecondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.peg.success.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
    }
    
    private func formatExpiryTime(_ expiryDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return "Expires at \(formatter.string(from: expiryDate))"
    }
}