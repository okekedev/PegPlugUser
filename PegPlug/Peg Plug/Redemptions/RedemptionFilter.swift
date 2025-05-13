//
//  RedemptionFilter.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


//
//  RedemptionFilter.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Redemption Filter
enum RedemptionFilter: String, CaseIterable {
    case active = "Active"
    case completed = "Completed"
    case expired = "Expired"
    
    var title: String {
        return self.rawValue
    }
}

// MARK: - Redemption History View Model
class RedemptionHistoryViewModel: ObservableObject {
    @Published var redemptionsWithDetails: [RedemptionWithDetails] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: RedemptionFilter = .active
    
    // Add error handler
    var errorHandler: ErrorHandler?
    
    var filteredRedemptions: [RedemptionWithDetails] {
        switch selectedFilter {
        case .active:
            return redemptionsWithDetails.filter { $0.redemption.status == Constants.RedemptionStatus.pending }
        case .completed:
            return redemptionsWithDetails.filter { $0.redemption.status == Constants.RedemptionStatus.completed }
        case .expired:
            return redemptionsWithDetails.filter { $0.redemption.status == Constants.RedemptionStatus.expired }
        }
    }
    
    var activeCount: Int {
        return redemptionsWithDetails.filter { $0.redemption.status == Constants.RedemptionStatus.pending }.count
    }
    
    var completedCount: Int {
        return redemptionsWithDetails.filter { $0.redemption.status == Constants.RedemptionStatus.completed }.count
    }
    
    var expiredCount: Int {
        return redemptionsWithDetails.filter { $0.redemption.status == Constants.RedemptionStatus.expired }.count
    }
    
    private let db = Firestore.firestore()
    
    func fetchRedemptions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Get the user's redemptions
        db.collection(Constants.Collections.redemptions)
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error loading redemptions: \(error.localizedDescription)"
                    self.errorHandler?.handle(AppError.database("Error loading redemptions: \(error.localizedDescription)"))
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                // Parse redemptions
                var redemptions: [Redemption] = []
                for document in documents {
                    let redemptionId = document.documentID
                    let data = document.data()
                    
                    let redemption = Redemption(id: redemptionId, data: data)
                    redemptions.append(redemption)
                }
                
                // Get unique deal, merchant, and location IDs
                let dealIds = Set(redemptions.map { $0.dealId })
                let merchantIds = Set(redemptions.map { $0.merchantId })
                let locationIds = Set(redemptions.map { $0.locationId })
                
                // Fetch all related entities
                let dispatchGroup = DispatchGroup()
                
                var deals: [String: Deal] = [:]
                var merchants: [String: Merchant] = [:]
                var locations: [String: Location] = [:]
                
                // Fetch deals
                dispatchGroup.enter()
                self.fetchDeals(ids: Array(dealIds)) { fetchedDeals in
                    deals = fetchedDeals
                    dispatchGroup.leave()
                }
                
                // Fetch merchants
                dispatchGroup.enter()
                self.fetchMerchants(ids: Array(merchantIds)) { fetchedMerchants in
                    merchants = fetchedMerchants
                    dispatchGroup.leave()
                }
                
                // Fetch locations
                dispatchGroup.enter()
                self.fetchLocations(ids: Array(locationIds)) { fetchedLocations in
                    locations = fetchedLocations
                    dispatchGroup.leave()
                }
                
                // When all fetches complete, update the UI
                dispatchGroup.notify(queue: .main) {
                    // Create redemption with details objects
                    self.redemptionsWithDetails = redemptions.map { redemption in
                        RedemptionWithDetails(
                            redemption: redemption,
                            deal: deals[redemption.dealId],
                            merchant: merchants[redemption.merchantId],
                            location: locations[redemption.locationId]
                        )
                    }
                    
                    self.isLoading = false
                }
            }
    }
    
    private func fetchDeals(ids: [String], completion: @escaping ([String: Deal]) -> Void) {
        guard !ids.isEmpty else {
            completion([:])
            return
        }
        
        // Firestore can only query up to 10 IDs at a time
        let chunkedIds = stride(from: 0, to: ids.count, by: 10).map {
            Array(ids[$0 ..< min($0 + 10, ids.count)])
        }
        
        let dispatchGroup = DispatchGroup()
        var result: [String: Deal] = [:]
        
        for chunk in chunkedIds {
            dispatchGroup.enter()
            
            db.collection(Constants.Collections.deals)
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    for document in documents {
                        let dealId = document.documentID
                        let data = document.data()
                        
                        let deal = Deal(id: dealId, data: data)
                        result[dealId] = deal
                    }
                }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(result)
        }
    }
    
    private func fetchMerchants(ids: [String], completion: @escaping ([String: Merchant]) -> Void) {
        guard !ids.isEmpty else {
            completion([:])
            return
        }
        
        // Firestore can only query up to 10 IDs at a time
        let chunkedIds = stride(from: 0, to: ids.count, by: 10).map {
            Array(ids[$0 ..< min($0 + 10, ids.count)])
        }
        
        let dispatchGroup = DispatchGroup()
        var result: [String: Merchant] = [:]
        
        for chunk in chunkedIds {
            dispatchGroup.enter()
            
            db.collection(Constants.Collections.merchants)
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    for document in documents {
                        let merchantId = document.documentID
                        let data = document.data()
                        
                        let merchant = Merchant(id: merchantId, data: data)
                        result[merchantId] = merchant
                    }
                }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(result)
        }
    }
    
    private func fetchLocations(ids: [String], completion: @escaping ([String: Location]) -> Void) {
        guard !ids.isEmpty else {
            completion([:])
            return
        }
        
        // Firestore can only query up to 10 IDs at a time
        let chunkedIds = stride(from: 0, to: ids.count, by: 10).map {
            Array(ids[$0 ..< min($0 + 10, ids.count)])
        }
        
        let dispatchGroup = DispatchGroup()
        var result: [String: Location] = [:]
        
        for chunk in chunkedIds {
            dispatchGroup.enter()
            
            db.collection(Constants.Collections.locations)
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    for document in documents {
                        let locationId = document.documentID
                        let data = document.data()
                        
                        let location = Location(id: locationId, data: data)
                        result[locationId] = location
                    }
                }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(result)
        }
    }
    
    // Add this function to set up the ErrorHandler
    func setupErrorHandler(_ handler: ErrorHandler) {
        self.errorHandler = handler
    }
}

// MARK: - Redemption With Details
struct RedemptionWithDetails: Identifiable {
    let id: String
    let redemption: Redemption
    let deal: Deal?
    let merchant: Merchant?
    let location: Location?
    
    init(redemption: Redemption, deal: Deal? = nil, merchant: Merchant? = nil, location: Location? = nil) {
        self.id = redemption.id
        self.redemption = redemption
        self.deal = deal
        self.merchant = merchant
        self.location = location
    }
}