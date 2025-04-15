//
//  PegsMapSection.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import MapKit

struct PegsMapSection: View {
    let locations: [LocationAnnotation]
    let onViewFullMap: () -> Void
    let onLocationTapped: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Map Header with subtle animation
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.peg.primaryRed)
                    
                    Text("Pegs Near Me")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.peg.textPrimary)
                }
                .pegShimmer()
                
                Spacer()
                
                Button(action: {
                    // Add haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onViewFullMap()
                }) {
                    HStack(spacing: 5) {
                        Text("Full Map")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.peg.primaryBlue)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.peg.primaryBlue)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.peg.primaryBlue.opacity(0.1))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
            
            // Helper text
            HStack {
                Text("Visit Pegs to unlock special deals!")
                    .font(.system(size: 13))
                    .foregroundColor(Color.peg.textSecondary)
                    .padding(.leading, 20)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.7))
            
            if !locations.isEmpty {
                // Enhanced Map
                EnhancedMapView(
                    locations: locations,
                    onTap: onLocationTapped
                )
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
            } else {
                // No locations placeholder
                VStack {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 40))
                        .foregroundColor(Color.peg.primaryBlue.opacity(0.6))
                    
                    Text("No pegs nearby")
                        .font(.headline)
                        .foregroundColor(Color.peg.textPrimary)
                        .padding(.top, 10)
                    
                    Text("Check back later for new opportunities")
                        .font(.subheadline)
                        .foregroundColor(Color.peg.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 5)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Preview
struct PegsMapSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.peg.background
                .ignoresSafeArea()
            
            // Create sample data
            let location1 = LocationAnnotation(
                id: "loc1",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                title: "Coffee Shop",
                subtitle: "Downtown",
                merchantId: "m1"
            )
            
            let location2 = LocationAnnotation(
                id: "loc2",
                coordinate: CLLocationCoordinate2D(latitude: 37.7850, longitude: -122.4000),
                title: "Bakery",
                subtitle: "Uptown",
                merchantId: "m2"
            )
            
            PegsMapSection(
                locations: [location1, location2],
                onViewFullMap: {},
                onLocationTapped: { _, _ in }
            )
            .padding()
        }
    }
}
