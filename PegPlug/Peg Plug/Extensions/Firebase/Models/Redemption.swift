//
//  Redemption.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//


import Foundation
import FirebaseFirestore

struct Redemption: Identifiable {
    let id: String
    let userId: String
    let dealId: String
    let merchantId: String
    let locationId: String
    let timestamp: Date
    let validityPeriod: Date
    let status: String
    let deviceId: String
    let notificationSent: Bool
    let redemptionLocation: GeoPoint
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.dealId = data["dealId"] as? String ?? ""
        self.merchantId = data["merchantId"] as? String ?? ""
        self.locationId = data["locationId"] as? String ?? ""
        
        if let timestampData = data["timestamp"] as? Timestamp {
            self.timestamp = timestampData.dateValue()
        } else {
            self.timestamp = Date()
        }
        
        if let validityData = data["validityPeriod"] as? Timestamp {
            self.validityPeriod = validityData.dateValue()
        } else {
            self.validityPeriod = Date().addingTimeInterval(3600) // 1 hour from now
        }
        
        self.status = data["status"] as? String ?? Constants.RedemptionStatus.pending
        self.deviceId = data["deviceId"] as? String ?? ""
        self.notificationSent = data["notificationSent"] as? Bool ?? false
        
        if let location = data["redemptionLocation"] as? GeoPoint {
            self.redemptionLocation = location
        } else {
            self.redemptionLocation = GeoPoint(latitude: 0, longitude: 0)
        }
    }
    
    var isValid: Bool {
        return status == Constants.RedemptionStatus.pending && Date() < validityPeriod
    }
    
    var remainingTime: TimeInterval {
        return validityPeriod.timeIntervalSince(Date())
    }
}