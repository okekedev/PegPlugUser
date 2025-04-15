//
//  AppDelegate.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        
        // Configure Firebase Messaging
        Messaging.messaging().delegate = self
        
        // Configure Google Sign-In
        guard let clientID = FirebaseApp.app()?.options.clientID else { return true }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Initialize LocationManager
        _ = LocationManager.shared
        
        return true
    }
    
    // Handle Google Sign-In
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - FCM Token handling
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            let dataDict: [String: String] = ["token": token]
            NotificationCenter.default.post(
                name: Notification.Name("FCMToken"),
                object: nil,
                userInfo: dataDict
            )
            
            // Store token in Firestore for this user if logged in
            if let userId = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()
                db.collection("users").document(userId).setData(["fcmToken": token], merge: true)
            }
        }
    }
    
    // MARK: - Remote Notification handling
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display notification even when app is in foreground
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification response based on action identifier
        if response.actionIdentifier == "SPIN_ACTION" {
            // Open slot machine with the provided merchant and location IDs
            if let merchantId = userInfo["merchantId"] as? String,
               let locationId = userInfo["locationId"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("OpenSlotMachine"),
                    object: nil,
                    userInfo: ["merchantId": merchantId, "locationId": locationId]
                )
            }
        } else if response.actionIdentifier == "VIEW_ACTION" || response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // Handle deal opening or default tap
            if let dealId = userInfo["dealId"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("OpenDeal"),
                    object: nil,
                    userInfo: ["dealId": dealId]
                )
            } else if let merchantId = userInfo["merchantId"] as? String {
                // If no specific deal, just open the app (the home screen will show the deals)
                NotificationCenter.default.post(
                    name: Notification.Name("OpenHome"),
                    object: nil,
                    userInfo: nil
                )
            }
        }
        
        completionHandler()
    }
}
