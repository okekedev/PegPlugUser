//
//  AuthenticationViewModel.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import FirebaseAuth
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Add this property to access the ErrorHandler
    var errorHandler: ErrorHandler?
    
    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    var isAdmin: Bool {
        return user?.role == "admin"
    }
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            
            if let userId = user?.uid {
                self?.fetchUserData(userId: userId)
            } else {
                self?.user = nil
            }
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Update fetchUserData to use ErrorHandler
    func fetchUserData(userId: String) {
        db.collection(Constants.Collections.users).document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                self?.errorHandler?.handle(AppError.database("Error fetching user data: \(error.localizedDescription)"))
                return
            }
            
            if let data = snapshot?.data() {
                self?.user = User(id: userId, data: data)
                
                // Check if we need to refresh daily spins
                if let lastSpinDate = (data["lastSpinDate"] as? Timestamp)?.dateValue() {
                    let calendar = Calendar.current
                    if !calendar.isDateInToday(lastSpinDate) {
                        // It's a new day, so grant new spins based on tier
                        let membershipTier = data["membershipTier"] as? String ?? Constants.MembershipTier.basic
                        let spinsToGrant = membershipTier == Constants.MembershipTier.premium ?
                            Constants.SlotMachine.premiumDailySpins : Constants.SlotMachine.basicDailySpins
                        
                        // Update in Firestore
                        self?.db.collection(Constants.Collections.users).document(userId).updateData([
                            "availableSpins": spinsToGrant,
                            "lastSpinDate": Timestamp(date: Date())
                        ])
                        
                        // Update the local user object
                        if var currentUser = self?.user {
                            let updatedData = [
                                "email": currentUser.email,
                                "displayName": currentUser.displayName,
                                "fcmToken": currentUser.fcmToken ?? "",
                                "notificationsEnabled": currentUser.notificationsEnabled,
                                "role": currentUser.role,
                                "membershipTier": membershipTier,
                                "availableSpins": spinsToGrant,
                                "lastSpinDate": Timestamp(date: Date())
                            ] as [String : Any]
                            
                            self?.user = User(id: userId, data: updatedData)
                        }
                    }
                }
            } else {
                // Create user document if it doesn't exist
                let userData: [String: Any] = [
                    "email": Auth.auth().currentUser?.email ?? "",
                    "displayName": Auth.auth().currentUser?.displayName ?? "",
                    "notificationsEnabled": true,
                    "role": "user", // Default role for new users
                    "membershipTier": Constants.MembershipTier.basic, // Default tier
                    "availableSpins": Constants.SlotMachine.basicDailySpins,
                    "lastSpinDate": Timestamp(date: Date())
                ]
                
                self?.db.collection(Constants.Collections.users).document(userId).setData(userData) { error in
                    if let error = error {
                        print("Error creating user document: \(error.localizedDescription)")
                        self?.errorHandler?.handle(AppError.database("Error creating user: \(error.localizedDescription)"))
                    } else {
                        self?.user = User(id: userId, data: userData)
                    }
                }
            }
        }
    }
    
    // Update signIn to use ErrorHandler
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.errorHandler?.handle(AppError.authentication(error.localizedDescription))
            }
        }
    }
    
    // Update signInWithGoogle to use ErrorHandler
    func signInWithGoogle(credential: AuthCredential) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.errorHandler?.handle(AppError.authentication(error.localizedDescription))
                return
            }
            
            // User is now signed in - fetchUserData will be called via the auth state listener
        }
    }
    
    // Update signInWithGoogle(fromViewController:) to use ErrorHandler
    func signInWithGoogle(fromViewController viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.errorMessage = "Firebase configuration error"
            self.errorHandler?.handle(AppError.unknown("Firebase configuration error"))
            return
        }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        isLoading = true
        errorMessage = nil
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.errorHandler?.handle(AppError.authentication(error.localizedDescription))
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                self.errorMessage = "Failed to get ID token"
                self.errorHandler?.handle(AppError.authentication("Failed to get ID token"))
                return
            }
            
            // Create Google credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            // Sign in with Firebase using the Google credential
            self.signInWithGoogle(credential: credential)
        }
    }
    
    // Update signUp to use ErrorHandler
    func signUp(email: String, password: String, displayName: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                self?.errorHandler?.handle(AppError.authentication(error.localizedDescription))
                return
            }
            
            if let user = result?.user {
                // Update display name
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { [weak self] error in
                    if let error = error {
                        self?.errorHandler?.handle(AppError.authentication(error.localizedDescription))
                    }
                    
                    // Save user data to Firestore
                    let userData: [String: Any] = [
                        "email": email,
                        "displayName": displayName,
                        "notificationsEnabled": true,
                        "role": "user", // Default role for new users
                        "membershipTier": Constants.MembershipTier.basic, // Default tier
                        "availableSpins": Constants.SlotMachine.basicDailySpins,
                        "lastSpinDate": Timestamp(date: Date())
                    ]
                    
                    self?.db.collection(Constants.Collections.users).document(user.uid).setData(userData) { error in
                        self?.isLoading = false
                        
                        if let error = error {
                            self?.errorMessage = error.localizedDescription
                            self?.errorHandler?.handle(AppError.database("Error creating user: \(error.localizedDescription)"))
                        }
                    }
                }
            }
        }
    }
    
    // Update signOut to use ErrorHandler
    func signOut() {
        do {
            // Sign out from Firebase Auth
            try Auth.auth().signOut()
            
            // Also sign out from Google
            GIDSignIn.sharedInstance.signOut()
            
        } catch {
            errorMessage = error.localizedDescription
            errorHandler?.handle(AppError.authentication("Error signing out: \(error.localizedDescription)"))
        }
    }
    
    // Update updateNotificationPreference to use ErrorHandler
    func updateNotificationPreference(enabled: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(Constants.Collections.users).document(userId).updateData([
            "notificationsEnabled": enabled
        ]) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.errorHandler?.handle(AppError.database(error.localizedDescription))
            } else if var updatedUser = self?.user {
                // Update local user object
                let role = updatedUser.role // Preserve the role
                let membershipTier = updatedUser.membershipTier // Preserve membership tier
                let availableSpins = updatedUser.availableSpins // Preserve spins
                let lastSpinDate = updatedUser.lastSpinDate // Preserve last spin date
                
                updatedUser = User(id: updatedUser.id, data: [
                    "email": updatedUser.email,
                    "displayName": updatedUser.displayName,
                    "fcmToken": updatedUser.fcmToken ?? "",
                    "notificationsEnabled": enabled,
                    "role": role, // Keep the existing role
                    "membershipTier": membershipTier, // Keep membership tier
                    "availableSpins": availableSpins, // Keep available spins
                    "lastSpinDate": lastSpinDate != nil ? Timestamp(date: lastSpinDate!) : Timestamp(date: Date()) // Keep last spin date
                ])
                self?.user = updatedUser
            }
        }
    }
    
    // Update updateMembershipTier to use ErrorHandler
    func updateMembershipTier(tier: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let isUpgrade = tier == Constants.MembershipTier.premium
        
        // If upgrading to premium, give the premium number of spins immediately
        let spinsToGrant = isUpgrade ? Constants.SlotMachine.premiumDailySpins : self.user?.availableSpins ?? Constants.SlotMachine.basicDailySpins
        
        db.collection(Constants.Collections.users).document(userId).updateData([
            "membershipTier": tier,
            "availableSpins": spinsToGrant,
            "lastSpinDate": Timestamp(date: Date())
        ]) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.errorHandler?.handle(AppError.database(error.localizedDescription))
            } else if var updatedUser = self?.user {
                // Update local user object
                let updatedData = [
                    "email": updatedUser.email,
                    "displayName": updatedUser.displayName,
                    "fcmToken": updatedUser.fcmToken ?? "",
                    "notificationsEnabled": updatedUser.notificationsEnabled,
                    "role": updatedUser.role,
                    "membershipTier": tier,
                    "availableSpins": spinsToGrant,
                    "lastSpinDate": Timestamp(date: Date())
                ] as [String : Any]
                
                self?.user = User(id: updatedUser.id, data: updatedData)
                
                // Schedule notification for daily spins
                if isUpgrade {
                    NotificationManager.shared.scheduleDailySpinsReminder(userTier: tier)
                }
            }
        }
    }
    
    // Update useSpins to use ErrorHandler
    func useSpins(count: Int) {
        guard let userId = Auth.auth().currentUser?.uid,
              let currentSpins = user?.availableSpins,
              currentSpins >= count else {
            errorHandler?.handleMessage("Not enough spins available", type: .validation)
            return
        }
        
        let newSpinCount = currentSpins - count
        
        db.collection(Constants.Collections.users).document(userId).updateData([
            "availableSpins": newSpinCount,
            "lastSpinDate": Timestamp(date: Date())
        ]) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.errorHandler?.handle(AppError.database(error.localizedDescription))
            } else if var updatedUser = self?.user {
                // Update local user object
                let updatedData = [
                    "email": updatedUser.email,
                    "displayName": updatedUser.displayName,
                    "fcmToken": updatedUser.fcmToken ?? "",
                    "notificationsEnabled": updatedUser.notificationsEnabled,
                    "role": updatedUser.role,
                    "membershipTier": updatedUser.membershipTier,
                    "availableSpins": newSpinCount,
                    "lastSpinDate": Timestamp(date: Date())
                ] as [String : Any]
                
                self?.user = User(id: updatedUser.id, data: updatedData)
            }
        }
    }
    
    // Add this function to set up the ErrorHandler
    func setupErrorHandler(_ handler: ErrorHandler) {
        self.errorHandler = handler
    }
}
