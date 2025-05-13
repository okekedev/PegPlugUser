//
//  RedemptionViewModel.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


//
//  RedemptionViewModel.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI
import Firebase
import FirebaseFirestore

class RedemptionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Add error handler
    var errorHandler: ErrorHandler?
    
    private let db = Firestore.firestore()
    
    func expireRedemption(redemptionId: String) {
        db.collection(Constants.Collections.redemptions).document(redemptionId).updateData([
            "status": Constants.RedemptionStatus.expired
        ]) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error updating redemption: \(error.localizedDescription)"
                self?.errorHandler?.handle(AppError.database("Error updating redemption: \(error.localizedDescription)"))
            }
        }
    }
    
    func cancelRedemption(redemptionId: String, completion: @escaping () -> Void) {
        isLoading = true
        
        db.collection(Constants.Collections.redemptions).document(redemptionId).updateData([
            "status": Constants.RedemptionStatus.expired
        ]) { [weak self] error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = "Error cancelling redemption: \(error.localizedDescription)"
                self?.errorHandler?.handle(AppError.database("Error cancelling redemption: \(error.localizedDescription)"))
            } else {
                completion()
            }
        }
    }
    
    func completeRedemption(redemptionId: String, completion: @escaping () -> Void) {
        isLoading = true
        
        // Get current timestamp for completion time
        let now = Date()
        
        db.collection(Constants.Collections.redemptions).document(redemptionId).updateData([
            "status": Constants.RedemptionStatus.completed,
            "completedAt": Timestamp(date: now)
        ]) { [weak self] error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = "Error completing redemption: \(error.localizedDescription)"
                self?.errorHandler?.handle(AppError.database("Error completing redemption: \(error.localizedDescription)"))
            } else {
                completion()
            }
        }
    }
    
    // Add this function to set up the ErrorHandler
    func setupErrorHandler(_ handler: ErrorHandler) {
        self.errorHandler = handler
    }
}