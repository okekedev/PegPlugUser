//
//  FullMapView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import MapKit

struct FullMapView: View {
    let locations: [String: Location]
    let merchants: [String: Merchant]
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State private var selectedLocation: Location?
    @State private var showDetail = false
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var locationAnnotations: [LocationAnnotation] {
        var annotations: [LocationAnnotation] = []
        
        for (locationId, location) in locations {
            if let merchant = merchants[location.merchantId] {
                annotations.append(
                    LocationAnnotation(
                        id: locationId,
                        coordinate: location.coordinate,
                        title: location.name,
                        subtitle: merchant.name,
                        merchantId: location.merchantId
                    )
                )
            }
        }
        
        // Filter by search text if provided
        if !searchText.isEmpty {
            return annotations.filter { annotation in
                annotation.title.lowercased().contains(searchText.lowercased()) ||
                annotation.subtitle.lowercased().contains(searchText.lowercased())
            }
        }
        
        return annotations
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $region, annotationItems: locationAnnotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        Button(action: {
                            if let location = locations[annotation.id] {
                                selectedLocation = location
                                showDetail = true
                            }
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
                                }
                                
                                // Pin point
                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.peg.primaryRed)
                                    .offset(y: -5)
                                
                                // Label
                                Text(annotation.title)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.peg.textPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: [.bottom])
                
                // Search bar and controls overlay at top
                VStack {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.peg.textSecondary)
                            .padding(.leading, 8)
                        
                        TextField("Search locations", text: $searchText)
                            .padding(.vertical, 10)
                            .autocapitalization(.none)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.peg.textSecondary)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    Spacer()
                    
                    // User location button
                    Button(action: {
                        // Center on user location if available
                        if let userLocation = LocationManager.shared.userLocation {
                            withAnimation {
                                region = MKCoordinateRegion(
                                    center: userLocation.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.peg.primaryBlue)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Pegs Map", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.peg.textPrimary)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            })
            .sheet(isPresented: $showDetail) {
                if let location = selectedLocation, let merchant = merchants[location.merchantId] {
                    LocationDetailView(location: location, merchant: merchant)
                }
            }
            .onAppear {
                updateMapRegion()
            }
            // Remove the onChange modifier that's causing the error
            // Instead, update the region when searchText changes
            .onChange(of: searchText) { _ in
                updateMapRegion()
            }
        }
    }
    
    // Update map region to fit all annotations
    private func updateMapRegion() {
        guard !locationAnnotations.isEmpty else { return }
        
        var minLat = locationAnnotations[0].coordinate.latitude
        var maxLat = locationAnnotations[0].coordinate.latitude
        var minLng = locationAnnotations[0].coordinate.longitude
        var maxLng = locationAnnotations[0].coordinate.longitude
        
        for annotation in locationAnnotations {
            minLat = min(minLat, annotation.coordinate.latitude)
            maxLat = max(maxLat, annotation.coordinate.latitude)
            minLng = min(minLng, annotation.coordinate.longitude)
            maxLng = max(maxLng, annotation.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLng - minLng) * 1.5
        )
        
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                region = MKCoordinateRegion(center: center, span: span)
            }
        }
    }
}

// Location Detail Sheet
struct LocationDetailView: View {
    let location: Location
    let merchant: Merchant
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Location header with merchant info
                    HStack(spacing: 15) {
                        // Merchant logo or placeholder
                        if !merchant.logo.isEmpty {
                            AsyncImage(url: URL(string: merchant.logo)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.peg.primaryBlue)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Text(merchant.name.prefix(1).uppercased())
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        } else {
                            Circle()
                                .fill(Color.peg.primaryBlue)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(merchant.name.prefix(1).uppercased())
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(merchant.name)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(location.name)
                                .font(.subheadline)
                                .foregroundColor(Color.peg.textSecondary)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Address
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.peg.primaryRed)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Address")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.peg.textSecondary)
                            
                            Text(location.address)
                                .font(.body)
                        }
                    }
                    
                    // Drive to location button
                    Button(action: {
                        openMaps(location: location)
                    }) {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "car.fill")
                                .font(.headline)
                            
                            Text("Drive to Location")
                                .font(.headline)
                            
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .background(Color.peg.primaryBlue)
                        .cornerRadius(12)
                    }
                    .padding(.top, 10)
                    
                    // Availability
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Available Deals")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                        
                        Text("Visit this Peg location to spin for exclusive deals!")
                            .font(.subheadline)
                            .foregroundColor(Color.peg.textSecondary)
                    }
                    
                    // Start spinning button
                    Button(action: {
                        // Dismiss this sheet and open slot machine
                        presentationMode.wrappedValue.dismiss()
                        
                        // Unfortunately we can't directly trigger the slot machine from here
                        // The parent view would need to handle this via a completion handler
                    }) {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "dice.fill")
                                .font(.headline)
                            
                            Text("Spin for Deals")
                                .font(.headline)
                            
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .background(Color.peg.primaryRed)
                        .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationBarTitle("Location Details", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.peg.textSecondary)
            })
        }
    }
    
    // Open Apple Maps with directions
    private func openMaps(location: Location) {
        let coordinate = location.coordinate
        
        // Open Apple Maps with directions
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - Preview
struct FullMapView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock data
        let mockLocations: [String: Location] = [
            "loc1": Location(id: "loc1", data: [
                "name": "Downtown Coffee",
                "address": "123 Main St",
                "latitude": 37.7749,
                "longitude": -122.4194,
                "merchantId": "m1"
            ]),
            "loc2": Location(id: "loc2", data: [
                "name": "Uptown Bakery",
                "address": "456 Market St",
                "latitude": 37.7850,
                "longitude": -122.4000,
                "merchantId": "m2"
            ])
        ]
        
        let mockMerchants: [String: Merchant] = [
            "m1": Merchant(id: "m1", data: [
                "name": "Coffee Co.",
                "logo": "",
                "active": true
            ]),
            "m2": Merchant(id: "m2", data: [
                "name": "Bakery Inc.",
                "logo": "",
                "active": true
            ])
        ]
        
        return FullMapView(locations: mockLocations, merchants: mockMerchants)
    }
}
