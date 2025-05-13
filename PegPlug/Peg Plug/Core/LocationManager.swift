//
//  LocationManager.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//

import CoreLocation
import SwiftUI
import Combine
import FirebaseCoreInternal
import Firebase
import FirebaseAuth
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Add a shared singleton instance
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var geofenceRegions = [CLCircularRegion]()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var enteredRegions = [String]()
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        // Fix for 'authorizationStatus()' was deprecated in iOS 14.0
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // meters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        
        setupGeofences()
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestLocationPermissionWithPrompt() {
        // First check current status
        let status: CLAuthorizationStatus
        
        // Fix for 'authorizationStatus()' was deprecated in iOS 14.0
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            // Show custom alert explaining why location is needed before requesting
            DispatchQueue.main.async {
                // Fix for 'windows' was deprecated in iOS 15.0
                if #available(iOS 15.0, *) {
                    // Get the active scene
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        self.showLocationPermissionAlert(on: rootViewController)
                    }
                } else {
                    // Fallback for iOS 14 and below
                    if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                        self.showLocationPermissionAlert(on: rootViewController)
                    }
                }
            }
            
        case .restricted, .denied:
            // Show alert to direct to Settings
            DispatchQueue.main.async {
                // Fix for 'windows' was deprecated in iOS 15.0
                if #available(iOS 15.0, *) {
                    // Get the active scene
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        self.showSettingsAlert(on: rootViewController)
                    }
                } else {
                    // Fallback for iOS 14 and below
                    if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                        self.showSettingsAlert(on: rootViewController)
                    }
                }
            }
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Already authorized, start location services
            self.locationManager.startUpdatingLocation()
            
        @unknown default:
            break
        }
    }
    
    // Helper method to show location permission alert
    private func showLocationPermissionAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Location Access",
            message: "PegPlug needs your location to find deals near you and notify you when you're close to participating merchants.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in
            self.locationManager.requestWhenInUseAuthorization()
        })
        
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    // Helper method to show settings alert
    private func showSettingsAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Location Access Required",
            message: "PegPlug needs location access to find nearby deals. Please enable location in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsUrl)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    func startMonitoring() {
        locationManager.startUpdatingLocation()
    }
    
    private func setupGeofences() {
        // Fetch active merchants from Firestore
        db.collection(Constants.Collections.merchants)
            .whereField("active", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching merchants: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // For each merchant, fetch their locations
                for merchantDoc in documents {
                    let merchantId = merchantDoc.documentID
                    let merchantData = merchantDoc.data()
                    let geofenceRadius = merchantData["geofenceRadius"] as? Double ?? Constants.geofenceRadius
                    
                    self?.db.collection(Constants.Collections.locations)
                        .whereField("merchantId", isEqualTo: merchantId)
                        .whereField("active", isEqualTo: true)
                        .getDocuments { locationSnapshot, locationError in
                            guard let locationDocuments = locationSnapshot?.documents else {
                                print("Error fetching locations: \(locationError?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            
                            for locationDoc in locationDocuments {
                                let locationData = locationDoc.data()
                                guard let latitude = locationData["latitude"] as? Double,
                                      let longitude = locationData["longitude"] as? Double else {
                                    continue
                                }
                                
                                // Create and register geofence
                                self?.addGeofence(
                                    latitude: latitude,
                                    longitude: longitude,
                                    radius: geofenceRadius * 1609.34, // Convert miles to meters
                                    identifier: "\(merchantId)_\(locationDoc.documentID)"
                                )
                            }
                        }
                }
            }
    }
    
    private func addGeofence(latitude: Double, longitude: Double, radius: Double, identifier: String) {
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            radius: radius,
            identifier: identifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        // Remove any existing regions with the same identifier
        for existingRegion in locationManager.monitoredRegions {
            if existingRegion.identifier == identifier {
                locationManager.stopMonitoring(for: existingRegion)
            }
        }
        
        // Start monitoring the new region
        locationManager.startMonitoring(for: region)
        geofenceRegions.append(region)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedAlways ||
           manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region.identifier)")
        
        // Fix for unused variable warning - just check if it's a circular region
        guard region is CLCircularRegion else { return }
        
        if let merchantLocation = parseRegionIdentifier(region.identifier) {
            enteredRegions.append(region.identifier)
            
            // Create a pending redemption record
            createPendingRedemption(
                merchantId: merchantLocation.merchantId,
                locationId: merchantLocation.locationId
            )
            
            // Send local notification
            NotificationManager.shared.sendGeofenceEntryNotification(
                merchantId: merchantLocation.merchantId,
                locationId: merchantLocation.locationId
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
        
        if let index = enteredRegions.firstIndex(of: region.identifier) {
            enteredRegions.remove(at: index)
        }
    }
    
    // Helper method to parse region identifier into component IDs
    private func parseRegionIdentifier(_ identifier: String) -> (merchantId: String, locationId: String)? {
        let components = identifier.split(separator: "_")
        guard components.count == 2 else { return nil }
        return (merchantId: String(components[0]), locationId: String(components[1]))
    }
    
    // Create a pending redemption when entering a merchant's geofence
    private func createPendingRedemption(merchantId: String, locationId: String) {
        guard let userId = Auth.auth().currentUser?.uid,
              let userLocation = userLocation else { return }
        
        // Fetch active deals for this merchant and location
        db.collection(Constants.Collections.deals)
            .whereField("merchantId", isEqualTo: merchantId)
            .whereField("locationIds", arrayContains: locationId)
            .whereField("active", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching deals: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Get current timestamp
                let now = Date()
                
                // Check each deal to see if it's valid
                for dealDoc in documents {
                    let dealId = dealDoc.documentID
                    let dealData = dealDoc.data()
                    
                    // Check date range validity
                    if let startDate = dealData["startDate"] as? Timestamp,
                       let endDate = dealData["endDate"] as? Timestamp {
                        let startDateTime = startDate.dateValue()
                        let endDateTime = endDate.dateValue()
                        
                        // Skip deals that haven't started or have ended
                        if now < startDateTime || now > endDateTime {
                            continue
                        }
                    }
                    
                    // Check if user has already redeemed this deal
                    self?.db.collection(Constants.Collections.redemptions)
                        .whereField("userId", isEqualTo: userId)
                        .whereField("dealId", isEqualTo: dealId)
                        .whereField("status", isEqualTo: Constants.RedemptionStatus.completed)
                        .getDocuments { redemptionSnapshot, redemptionError in
                            if let redemptionCount = redemptionSnapshot?.documents.count, redemptionCount > 0 {
                                // User already redeemed this deal
                                return
                            }
                            
                            // Check if there's already a pending redemption
                            self?.db.collection(Constants.Collections.redemptions)
                                .whereField("userId", isEqualTo: userId)
                                .whereField("dealId", isEqualTo: dealId)
                                .whereField("status", isEqualTo: Constants.RedemptionStatus.pending)
                                .getDocuments { pendingSnapshot, pendingError in
                                    if let pendingCount = pendingSnapshot?.documents.count, pendingCount > 0 {
                                        // Already has a pending redemption
                                        return
                                    }
                                    
                                    // Create new redemption record
                                    let validityEndTime = now.addingTimeInterval(Constants.redemptionValidityPeriod)
                                    
                                    let redemptionData: [String: Any] = [
                                        "userId": userId,
                                        "dealId": dealId,
                                        "merchantId": merchantId,
                                        "locationId": locationId,
                                        "timestamp": Timestamp(date: now),
                                        "validityPeriod": Timestamp(date: validityEndTime),
                                        "status": Constants.RedemptionStatus.pending,
                                        "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
                                        "notificationSent": true,
                                        "redemptionLocation": GeoPoint(latitude: userLocation.coordinate.latitude,
                                                                      longitude: userLocation.coordinate.longitude)
                                    ]
                                    
                                    self?.db.collection(Constants.Collections.redemptions)
                                        .addDocument(data: redemptionData) { error in
                                            if let error = error {
                                                print("Error creating redemption: \(error.localizedDescription)")
                                            } else {
                                                print("Created pending redemption for deal: \(dealId)")
                                            }
                                        }
                                }
                        }
                }
            }
    }
}
