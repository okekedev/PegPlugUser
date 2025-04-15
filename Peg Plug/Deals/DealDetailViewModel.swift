//
//  DealDetailViewModel.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//

import SwiftUI
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class DealDetailViewModel: ObservableObject {
    let deal: Deal
    
    @Published var merchant: Merchant?
    @Published var locations: [Location] = []
    @Published var closestLocation: Location?
    @Published var activeRedemption: Redemption?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var canRedeem = false
    
    private let db = Firestore.firestore()
    
    init(deal: Deal) {
        self.deal = deal
    }
    
    func loadMerchantAndLocations() {
        isLoading = true
        
        let dispatchGroup = DispatchGroup()
        
        // Fetch merchant
        dispatchGroup.enter()
        db.collection(Constants.Collections.merchants).document(deal.merchantId).getDocument { [weak self] snapshot, error in
            defer { dispatchGroup.leave() }
            
            guard let self = self, let data = snapshot?.data() else {
                self?.errorMessage = "Failed to load merchant information"
                return
            }
            
            self.merchant = Merchant(id: self.deal.merchantId, data: data)
        }
        
        // Fetch locations
        if !deal.locationIds.isEmpty {
            dispatchGroup.enter()
            
            // Firestore can only query up to 10 IDs at a time
            let chunkedIds = stride(from: 0, to: deal.locationIds.count, by: 10).map {
                Array(deal.locationIds[$0 ..< min($0 + 10, deal.locationIds.count)])
            }
            
            let locationDispatchGroup = DispatchGroup()
            
            for chunk in chunkedIds {
                locationDispatchGroup.enter()
                
                db.collection(Constants.Collections.locations)
                    .whereField(FieldPath.documentID(), in: chunk)
                    .getDocuments { [weak self] snapshot, error in
                        defer { locationDispatchGroup.leave() }
                        
                        guard let self = self, let documents = snapshot?.documents else { return }
                        
                        for document in documents {
                            let locationId = document.documentID
                            let data = document.data()
                            
                            let location = Location(id: locationId, data: data)
                            self.locations.append(location)
                        }
                    }
            }
            
            locationDispatchGroup.notify(queue: .main) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.isLoading = false
        }
    }
    
    func checkForActiveRedemption() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(Constants.Collections.redemptions)
            .whereField("userId", isEqualTo: userId)
            .whereField("dealId", isEqualTo: deal.id)
            .whereField("status", isEqualTo: Constants.RedemptionStatus.pending)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = "Error checking redemptions: \(error.localizedDescription)"
                    return
                }
                
                if let document = snapshot?.documents.first {
                    let redemptionId = document.documentID
                    let data = document.data()
                    
                    let redemption = Redemption(id: redemptionId, data: data)
                    
                    // Only count it as active if it's still valid (not expired)
                    if redemption.isValid {
                        self?.activeRedemption = redemption
                    } else {
                        // If it's expired, update the status in Firestore
                        self?.db.collection(Constants.Collections.redemptions).document(redemptionId)
                            .updateData([
                                "status": Constants.RedemptionStatus.expired
                            ])
                    }
                }
            }
    }
    
    func checkIfUserInRange(userLocation: CLLocation?) {
        guard let userLocation = userLocation, !locations.isEmpty else {
            canRedeem = false
            return
        }
        
        var minDistance = Double.greatestFiniteMagnitude
        var closestLoc: Location?
        
        // Find the closest location
        for location in locations {
            let locationCL = CLLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            let distance = userLocation.distance(from: locationCL)
            if distance < minDistance {
                minDistance = distance
                closestLoc = location
            }
        }
        
        self.closestLocation = closestLoc
        
        // Check if user is within geofence radius
        if let merchant = merchant, let _ = closestLoc {
            // Convert geofenceRadius from miles to meters
            let radiusInMeters = merchant.geofenceRadius * 1609.34
            
            // User can redeem if they're within the geofence radius
            canRedeem = minDistance <= radiusInMeters
        } else {
            canRedeem = false
        }
    }
    
    func redeemDeal(userLocation: CLLocation?) {
        guard let userId = Auth.auth().currentUser?.uid,
              let userLocation = userLocation,
              let closestLocation = closestLocation,
              canRedeem else {
            errorMessage = "You must be at the merchant location to redeem this deal"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Get current timestamp
        let now = Date()
        let validityEndTime = now.addingTimeInterval(Constants.redemptionValidityPeriod)
        
        // Check if user already has a completed redemption for this deal
        db.collection(Constants.Collections.redemptions)
            .whereField("userId", isEqualTo: userId)
            .whereField("dealId", isEqualTo: deal.id)
            .whereField("status", isEqualTo: Constants.RedemptionStatus.completed)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Error checking redemptions: \(error.localizedDescription)"
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    // User has already redeemed this deal
                    self.isLoading = false
                    self.errorMessage = "You have already redeemed this deal"
                    return
                }
                
                // Check if there's already a pending redemption
                self.db.collection(Constants.Collections.redemptions)
                    .whereField("userId", isEqualTo: userId)
                    .whereField("dealId", isEqualTo: self.deal.id)
                    .whereField("status", isEqualTo: Constants.RedemptionStatus.pending)
                    .getDocuments { pendingSnapshot, pendingError in
                        if let pendingError = pendingError {
                            self.isLoading = false
                            self.errorMessage = "Error checking pending redemptions: \(pendingError.localizedDescription)"
                            return
                        }
                        
                        if let pendingDoc = pendingSnapshot?.documents.first {
                            // Already has a pending redemption - use that one
                            let pendingId = pendingDoc.documentID
                            let pendingData = pendingDoc.data()
                            let pendingRedemption = Redemption(id: pendingId, data: pendingData)
                            
                            self.activeRedemption = pendingRedemption
                            self.isLoading = false
                            return
                        }
                        
                        // Create new redemption record
                        let redemptionData: [String: Any] = [
                            "userId": userId,
                            "dealId": self.deal.id,
                            "merchantId": self.deal.merchantId,
                            "locationId": closestLocation.id,
                            "timestamp": Timestamp(date: now),
                            "validityPeriod": Timestamp(date: validityEndTime),
                            "status": Constants.RedemptionStatus.pending,
                            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
                            "notificationSent": true,
                            "redemptionLocation": GeoPoint(
                                latitude: userLocation.coordinate.latitude,
                                longitude: userLocation.coordinate.longitude
                            )
                        ]
                        
                        self.db.collection(Constants.Collections.redemptions)
                            .addDocument(data: redemptionData) { error in
                                self.isLoading = false
                                
                                if let error = error {
                                    self.errorMessage = "Error creating redemption: \(error.localizedDescription)"
                                } else {
                                    // Get the newly created redemption
                                    self.checkForActiveRedemption()
                                    
                                    // Schedule an expiration reminder
                                    NotificationManager.shared.scheduleExpirationReminder(
                                        redemptionId: self.activeRedemption?.id ?? "",
                                        dealTitle: self.deal.title,
                                        expiryTime: validityEndTime
                                    )
                                }
                            }
                    }
            }
    }
}
