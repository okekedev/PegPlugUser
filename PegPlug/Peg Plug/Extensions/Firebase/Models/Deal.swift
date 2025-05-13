//
//  Deal.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//


import Foundation
import FirebaseFirestore

struct Deal: Identifiable {
    let id: String
    let title: String
    let description: String
    let terms: String
    let imageUrl: String
    let merchantId: String
    let locationIds: [String]
    let startDate: Date
    let endDate: Date
    let totalRedeemLimit: Int
    let active: Bool
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.title = data["title"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.terms = data["terms"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.merchantId = data["merchantId"] as? String ?? ""
        self.locationIds = data["locationIds"] as? [String] ?? []
        
        if let startTimestamp = data["startDate"] as? Timestamp {
            self.startDate = startTimestamp.dateValue()
        } else {
            self.startDate = Date()
        }
        
        if let endTimestamp = data["endDate"] as? Timestamp {
            self.endDate = endTimestamp.dateValue()
        } else {
            self.endDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
        }
        
        self.totalRedeemLimit = data["totalRedeemLimit"] as? Int ?? 0
        self.active = data["active"] as? Bool ?? false
    }
    
    var isActive: Bool {
        let now = Date()
        return active && now >= startDate && now <= endDate
    }
}