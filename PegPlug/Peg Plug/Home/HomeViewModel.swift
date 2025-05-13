//
//  HomeViewModel.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import CoreLocation
import FirebaseAuth

class HomeViewModel: ObservableObject {
    // User data
    @Published var availableSpins = 0
    @Published var userTier = "basic"
    
    // Deal data
    @Published var deals: [Deal] = []
    @Published var merchants: [String: Merchant] = [:]
    @Published var locations: [String: Location] = [:]
    @Published var activeRedemptions: [String: Redemption] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Navigation handler
    var navigateToProfile: (() -> Void)?
    
    private let db = Firestore.firestore()
    private let locationManager = LocationManager.shared
    
    // Computed properties
    var recentDeals: [Deal] {
        // Return the most recent deals (limited to 10)
        return Array(deals.prefix(10))
    }
    
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
        
        return annotations
    }
    
    var nearestMerchant: Merchant? {
        guard let userLocation = locationManager.userLocation else { return merchants.values.first }
        
        var nearestMerchantId: String?
        var minDistance = Double.greatestFiniteMagnitude
        
        for (locationId, location) in locations {
            let locationCoordinate = CLLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            let distance = userLocation.distance(from: locationCoordinate)
            if distance < minDistance {
                minDistance = distance
                nearestMerchantId = location.merchantId
            }
        }
        
        if let merchantId = nearestMerchantId {
            return merchants[merchantId]
        }
        
        return merchants.values.first
    }
    
    var nearestLocation: Location? {
        guard let userLocation = locationManager.userLocation else { return locations.values.first }
        
        var nearestLocationId: String?
        var minDistance = Double.greatestFiniteMagnitude
        
        for (locationId, location) in locations {
            let locationCoordinate = CLLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            let distance = userLocation.distance(from: locationCoordinate)
            if distance < minDistance {
                minDistance = distance
                nearestLocationId = locationId
            }
        }
        
        if let locationId = nearestLocationId {
            return locations[locationId]
        }
        
        return locations.values.first
    }
    
    // MARK: - Methods
    
    // Load user data including spins and tier
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(Constants.Collections.users).document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if let userData = snapshot?.data() {
                DispatchQueue.main.async {
                    self?.userTier = userData["membershipTier"] as? String ?? "basic"
                    self?.availableSpins = userData["availableSpins"] as? Int ?? 0
                }
                
                // Check if we need to refresh daily spins
                if let lastSpinDate = (userData["lastSpinDate"] as? Timestamp)?.dateValue() {
                    let calendar = Calendar.current
                    if !calendar.isDateInToday(lastSpinDate) {
                        // It's a new day, so grant new spins based on tier
                        let spinsToGrant = self?.userTier == "premium" ? 3 : 1
                        
                        // Update in Firestore
                        self?.db.collection(Constants.Collections.users).document(userId).updateData([
                            "availableSpins": spinsToGrant,
                            "lastSpinDate": Timestamp(date: Date())
                        ])
                        
                        // Update local value
                        DispatchQueue.main.async {
                            self?.availableSpins = spinsToGrant
                        }
                    }
                }
            }
        }
    }
    
    // Load deals, merchants, and locations
    func loadDealsAndMerchants() {
        isLoading = true
        
        // Load active deals
        db.collection(Constants.Collections.deals)
            .whereField("active", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                // Process deals
                var deals: [Deal] = []
                var merchantIds = Set<String>()
                var locationIds = Set<String>()
                
                for document in documents {
                    let dealId = document.documentID
                    let data = document.data()
                    
                    let deal = Deal(id: dealId, data: data)
                    
                    // Only add active deals within the date range
                    if deal.isActive {
                        deals.append(deal)
                        merchantIds.insert(deal.merchantId)
                        locationIds.formUnion(deal.locationIds)
                    }
                }
                
                DispatchQueue.main.async {
                    self.deals = deals
                }
                
                // Load merchants
                self.loadMerchants(Array(merchantIds)) {
                    // Load locations
                    self.loadLocations(Array(locationIds)) {
                        // Load active redemptions
                        self.loadActiveRedemptions {
                            DispatchQueue.main.async {
                                self.isLoading = false
                            }
                        }
                    }
                }
            }
    }
    
    // Load merchants by IDs
    private func loadMerchants(_ merchantIds: [String], completion: @escaping () -> Void) {
        guard !merchantIds.isEmpty else {
            completion()
            return
        }
        
        // Firestore can only query up to 10 IDs at a time
        let chunkedIds = stride(from: 0, to: merchantIds.count, by: 10).map {
            Array(merchantIds[$0 ..< min($0 + 10, merchantIds.count)])
        }
        
        let dispatchGroup = DispatchGroup()
        var merchants: [String: Merchant] = [:]
        
        for chunk in chunkedIds {
            dispatchGroup.enter()
            
            db.collection(Constants.Collections.merchants)
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { [weak self] snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    for document in documents {
                        let merchantId = document.documentID
                        let data = document.data()
                        
                        let merchant = Merchant(id: merchantId, data: data)
                        merchants[merchantId] = merchant
                    }
                }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.merchants = merchants
            completion()
        }
    }
    
    // Load locations by IDs
    private func loadLocations(_ locationIds: [String], completion: @escaping () -> Void) {
        guard !locationIds.isEmpty else {
            completion()
            return
        }
        
        // Firestore can only query up to 10 IDs at a time
        let chunkedIds = stride(from: 0, to: locationIds.count, by: 10).map {
            Array(locationIds[$0 ..< min($0 + 10, locationIds.count)])
        }
        
        let dispatchGroup = DispatchGroup()
        var locations: [String: Location] = [:]
        
        for chunk in chunkedIds {
            dispatchGroup.enter()
            
            db.collection(Constants.Collections.locations)
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { [weak self] snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    for document in documents {
                        let locationId = document.documentID
                        let data = document.data()
                        
                        let location = Location(id: locationId, data: data)
                        locations[locationId] = location
                    }
                }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.locations = locations
            completion()
        }
    }
    
    // Load active redemptions
    private func loadActiveRedemptions(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion()
            return
        }
        
        db.collection(Constants.Collections.redemptions)
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: Constants.RedemptionStatus.pending)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion()
                    return
                }
                
                var redemptions: [String: Redemption] = [:]
                
                for document in documents {
                    let redemptionId = document.documentID
                    let data = document.data()
                    
                    let redemption = Redemption(id: redemptionId, data: data)
                    
                    if redemption.isValid {
                        redemptions[redemption.dealId] = redemption
                    }
                }
                
                DispatchQueue.main.async {
                    self?.activeRedemptions = redemptions
                }
                
                completion()
            }
    }
    
    // Check if a deal has an active redemption
    func hasActiveRedemption(for dealId: String) -> Bool {
        return activeRedemptions[dealId] != nil
    }
}
