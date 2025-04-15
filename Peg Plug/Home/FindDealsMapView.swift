//
//  FindDealsMapView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI
import MapKit

// MARK: - Location Annotation
struct LocationAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
    let merchantId: String
}

// MARK: - Find Deals Map Component
struct FindDealsMapView: View {
    let locations: [LocationAnnotation]
    let onTap: (String, String) -> Void
    let onViewFullMap: () -> Void
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Find Deals Near You")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.peg.textPrimary)
                
                Spacer()
                
                Button(action: onViewFullMap) {
                    HStack(spacing: 5) {
                        Text("View All")
                            .font(.subheadline)
                            .foregroundColor(Color.peg.primaryBlue)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundColor(Color.peg.primaryBlue)
                    }
                }
            }
            .padding()
            .background(Color.white)
            
            // Map
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Button(action: {
                        onTap(location.id, location.merchantId)
                    }) {
                        VStack(spacing: 0) {
                            // Pin head
                            Circle()
                                .fill(Color.peg.primaryRed)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                            
                            // Pin point
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.peg.primaryRed)
                                .offset(y: -5)
                        }
                    }
                }
            }
            .frame(height: 240)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 10, x: 0, y: 4)
        .onAppear {
            updateMapRegion()
        }
    }
    
    // Update map region based on locations
    private func updateMapRegion() {
        guard !locations.isEmpty else { return }
        
        var minLat = locations[0].coordinate.latitude
        var maxLat = locations[0].coordinate.latitude
        var minLng = locations[0].coordinate.longitude
        var maxLng = locations[0].coordinate.longitude
        
        for location in locations {
            minLat = min(minLat, location.coordinate.latitude)
            maxLat = max(maxLat, location.coordinate.latitude)
            minLng = min(minLng, location.coordinate.longitude)
            maxLng = max(maxLng, location.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLng - minLng) * 1.5
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Preview
struct FindDealsMapView_Previews: PreviewProvider {
    static var previews: some View {
        FindDealsMapView(
            locations: [
                LocationAnnotation(
                    id: "location1",
                    coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                    title: "Coffee Shop",
                    subtitle: "Coffee Co.",
                    merchantId: "merchant1"
                ),
                LocationAnnotation(
                    id: "location2",
                    coordinate: CLLocationCoordinate2D(latitude: 37.7850, longitude: -122.4100),
                    title: "Burger Place",
                    subtitle: "Burger Co.",
                    merchantId: "merchant2"
                )
            ],
            onTap: { _, _ in },
            onViewFullMap: {}
        )
        .frame(height: 300)
        .cornerRadius(16)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
