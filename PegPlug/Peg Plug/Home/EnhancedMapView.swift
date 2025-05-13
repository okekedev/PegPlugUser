//
//  EnhancedMapView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI
import MapKit

struct EnhancedMapView: View {
    let locations: [LocationAnnotation]
    let onTap: (String, String) -> Void
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showsPinAnimation = false
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    // Custom pin with tap action
                    Button(action: {
                        onTap(location.id, location.merchantId)
                    }) {
                        VStack(spacing: 0) {
                            // Pin head with animation
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 26, height: 26)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                Circle()
                                    .fill(Color.peg.primaryRed)
                                    .frame(width: 20, height: 20)
                                
                                // "P" for "Peg"
                                Text("P")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                
                                // Pulse animation
                                if showsPinAnimation {
                                    Circle()
                                        .stroke(Color.peg.primaryRed, lineWidth: 2)
                                        .frame(width: 36, height: 36)
                                        .scaleEffect(showsPinAnimation ? 1.6 : 1.0)
                                        .opacity(showsPinAnimation ? 0 : 0.6)
                                        .animation(
                                            Animation.easeOut(duration: 1.5)
                                                .repeatForever(autoreverses: false)
                                                .delay(Double.random(in: 0...2)), // Random delays for natural feel
                                            value: showsPinAnimation
                                        )
                                }
                            }
                            
                            // Pin point
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.peg.primaryRed)
                                .offset(y: -5)
                        }
                        .scaleEffect(showsPinAnimation ? 1.0 + 0.05 * sin(Date().timeIntervalSince1970 * 2 + Double(location.id.hashValue)) : 1.0)
                    }
                }
            }
            
            // Subtle gradient overlay at top and bottom
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
                
                Spacer()
                
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0), Color.white.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)
            }
        }
        .onAppear {
            // Center the map on the locations
            updateMapRegion()
            
            // Start pin animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showsPinAnimation = true
            }
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
        
        withAnimation(.easeInOut(duration: 0.8)) {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
}

// MARK: - Preview
struct EnhancedMapView_Previews: PreviewProvider {
    static var previews: some View {
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
        
        EnhancedMapView(
            locations: [location1, location2],
            onTap: { _, _ in }
        )
        .frame(height: 300)
        .cornerRadius(16)
    }
}