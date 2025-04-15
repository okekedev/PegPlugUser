import Foundation

struct Constants {
    static let geofenceRadius: Double = 0.5 // in miles
    static let redemptionValidityPeriod: TimeInterval = 120 * 60 // 60 minutes
    
    struct Collections {
        static let merchants = "merchants"
        static let locations = "locations"
        static let deals = "deals"
        static let redemptions = "redemptions"
        static let users = "users"
    }
    
    struct RedemptionStatus {
        static let pending = "pending"
        static let completed = "completed"
        static let expired = "expired"
    }
    
    struct MembershipTier {
        static let basic = "basic"
        static let premium = "premium"
    }
    
    struct SlotMachine {
        static let basicDailySpins = 1
        static let premiumDailySpins = 3
        static let basicWinChance = 0.3 // 30% chance of winning
        static let premiumWinChance = 0.4 // 40% chance of winning
    }
}
