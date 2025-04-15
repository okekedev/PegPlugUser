//
//  NotificationManager.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//

import UserNotifications
import Firebase
import FirebaseFirestore

class NotificationManager {
    static let shared = NotificationManager()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Send local notification when user enters a merchant's geofence
    func sendGeofenceEntryNotification(merchantId: String, locationId: String) {
        // Get merchant and location info
        let merchantRef = db.collection(Constants.Collections.merchants).document(merchantId)
        
        merchantRef.getDocument { [weak self] merchantDoc, merchantError in
            guard let merchantData = merchantDoc?.data(),
                  let merchantName = merchantData["name"] as? String else {
                print("Error fetching merchant: \(merchantError?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Fetch active deals for this merchant and location
            self?.db.collection(Constants.Collections.deals)
                .whereField("merchantId", isEqualTo: merchantId)
                .whereField("locationIds", arrayContains: locationId)
                .whereField("active", isEqualTo: true)
                .getDocuments { snapshot, error in
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        print("No active deals found for notification")
                        return
                    }
                    
                    // Create and schedule the notification
                    let content = UNMutableNotificationContent()
                    content.title = "Lucky Spins at \(merchantName)"
                    
                    if documents.count == 1, let dealData = documents.first?.data(),
                       let dealTitle = dealData["title"] as? String {
                        content.body = "Try your luck at \(merchantName)! Spin to win: \(dealTitle)"
                        content.userInfo = ["dealId": documents.first!.documentID,
                                           "merchantId": merchantId,
                                           "locationId": locationId,
                                           "notificationType": "lucky_spin"]
                    } else {
                        content.body = "Try your luck at \(merchantName)! Spin to win one of \(documents.count) exclusive deals!"
                        content.userInfo = ["merchantId": merchantId,
                                           "locationId": locationId,
                                           "notificationType": "lucky_spin"]
                    }
                    
                    content.sound = .default
                    
                    // Add actions
                    let spinAction = UNNotificationAction(
                        identifier: "SPIN_ACTION",
                        title: "Spin to Win",
                        options: .foreground
                    )
                    
                    let viewAction = UNNotificationAction(
                        identifier: "VIEW_ACTION",
                        title: "View Deals",
                        options: .foreground
                    )
                    
                    let category = UNNotificationCategory(
                        identifier: "LUCKY_SPIN_CATEGORY",
                        actions: [spinAction, viewAction],
                        intentIdentifiers: [],
                        options: []
                    )
                    
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                    content.categoryIdentifier = "LUCKY_SPIN_CATEGORY"
                    
                    // Create the request
                    let request = UNNotificationRequest(
                        identifier: UUID().uuidString,
                        content: content,
                        trigger: nil
                    )
                    
                    // Schedule the request
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
    
    // Send notification when a deal is about to expire
    func scheduleExpirationReminder(redemptionId: String, dealTitle: String, expiryTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Deal Expiring Soon"
        content.body = "Your \(dealTitle) deal is about to expire. Use it now!"
        content.sound = .default
        content.userInfo = ["redemptionId": redemptionId]
        
        // Notify 10 minutes before expiry
        let timeUntilExpiry = expiryTime.timeIntervalSinceNow - 600
        
        // Only schedule if we have at least 30 seconds until the notification should fire
        if timeUntilExpiry > 30 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilExpiry, repeats: false)
            let request = UNNotificationRequest(identifier: "expiry-\(redemptionId)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling expiration notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Send notification for spin results
    func sendSpinResultNotification(dealTitle: String, merchantName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🎰 Lucky Spin Winner!"
        content.body = "Congratulations! You won \(dealTitle) at \(merchantName). Tap to view your prize."
        content.sound = UNNotificationSound.default
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        // Schedule the request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling win notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Send notification for daily spins refresh
    func scheduleDailySpinsReminder(userTier: String) {
        let content = UNMutableNotificationContent()
        content.title = "🎰 Daily Spins Available!"
        
        let spinsCount = userTier == "premium" ? Constants.SlotMachine.premiumDailySpins : Constants.SlotMachine.basicDailySpins
        content.body = "Your \(spinsCount) daily spin\(spinsCount > 1 ? "s are" : " is") now available! Visit any location to try your luck."
        content.sound = UNNotificationSound.default
        
        // Create a date component to trigger at 10:00 AM tomorrow
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "daily-spins-reminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule the request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily spins reminder: \(error.localizedDescription)")
            }
        }
    }
}
