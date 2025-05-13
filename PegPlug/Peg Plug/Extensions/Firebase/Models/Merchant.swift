//
//  Merchant.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//


import Foundation
import FirebaseFirestore

struct Merchant: Identifiable {
    let id: String
    let name: String
    let logo: String
    let geofenceRadius: Double
    let merchantType: String
    let active: Bool
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.logo = data["logo"] as? String ?? ""
        self.geofenceRadius = data["geofenceRadius"] as? Double ?? 0.5
        self.merchantType = data["merchantType"] as? String ?? ""
        self.active = data["active"] as? Bool ?? false
    }
}