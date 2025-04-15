//
//  Location.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//


import Foundation
import CoreLocation
import MapKit

struct Location: Identifiable {
    let id: String
    let placeId: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let merchantId: String
    let businessHours: [String: BusinessHours]
    let active: Bool
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.placeId = data["placeId"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.address = data["address"] as? String ?? ""
        
        let latitude = data["latitude"] as? Double ?? 0
        let longitude = data["longitude"] as? Double ?? 0
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.merchantId = data["merchantId"] as? String ?? ""
        
        var hours: [String: BusinessHours] = [:]
        if let businessHoursData = data["businessHours"] as? [String: [String: Any]] {
            for (day, hoursData) in businessHoursData {
                hours[day] = BusinessHours(
                    open: hoursData["open"] as? String ?? "00:00",
                    close: hoursData["close"] as? String ?? "00:00"
                )
            }
        }
        self.businessHours = hours
        
        self.active = data["active"] as? Bool ?? false
    }
}

struct BusinessHours {
    let open: String
    let close: String
}