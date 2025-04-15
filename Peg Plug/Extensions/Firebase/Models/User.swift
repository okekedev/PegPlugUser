// User.swift
import FirebaseFirestore

struct User {
    let id: String
    let email: String
    let displayName: String
    let fcmToken: String?
    let notificationsEnabled: Bool
    let role: String
    let membershipTier: String
    let availableSpins: Int
    let lastSpinDate: Date?
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.email = data["email"] as? String ?? ""
        self.displayName = data["displayName"] as? String ?? ""
        self.fcmToken = data["fcmToken"] as? String
        self.notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
        self.role = data["role"] as? String ?? "user" // Default to regular user
        self.membershipTier = data["membershipTier"] as? String ?? "basic" // Default to basic tier
        self.availableSpins = data["availableSpins"] as? Int ?? 0
        
        if let lastSpinTimestamp = data["lastSpinDate"] as? Timestamp {
            self.lastSpinDate = lastSpinTimestamp.dateValue()
        } else {
            self.lastSpinDate = nil
        }
    }
}
