import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

class SlotMachineViewModel: ObservableObject {
    @Published var availableSpins = 0
    @Published var userTier = "basic"
    @Published var reelSymbols = ["🎰", "🎰", "🎰"]
    @Published var hasWon = false
    @Published var wonDeal: Deal?
    @Published var allDeals: [Deal] = []
    @Published var merchantName = ""
    @Published var showUpgradeAlert = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var userId: String?
    private var currentMerchantId: String?
    private var currentLocationId: String?
    private let symbols = ["🎰", "💎", "7️⃣", "🍒", "🎲", "💵", "🍀"]
    
    // Flag to enable test mode with 1000 spins
    private let testMode = true
    
    var canSpin: Bool {
        return availableSpins > 0
    }
    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        self.userId = userId
        
        // For testing: immediately set 1000 spins if test mode is enabled
        if testMode {
            self.userTier = "premium"
            self.availableSpins = 1000
            
            // Update in Firestore (optional for testing)
            self.db.collection(Constants.Collections.users).document(userId).updateData([
                "availableSpins": 1000,
                "membershipTier": "premium",
                "lastSpinDate": Timestamp(date: Date())
            ])
            
            return
        }
        
        // Normal loading logic (when not in test mode)
        db.collection(Constants.Collections.users).document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if let userData = snapshot?.data() {
                self?.userTier = userData["membershipTier"] as? String ?? "basic"
                self?.availableSpins = userData["availableSpins"] as? Int ?? 0
                
                // If no available spins and we're on a new day, add default spins
                if self?.availableSpins == 0 {
                    if let lastSpinDate = (userData["lastSpinDate"] as? Timestamp)?.dateValue() {
                        let calendar = Calendar.current
                        if !calendar.isDateInToday(lastSpinDate) {
                            // It's a new day, so grant new spins based on tier
                            let spinsToGrant = self?.userTier == "premium" ? 3 : 1
                            self?.availableSpins = spinsToGrant
                            
                            // Update in Firestore
                            self?.db.collection(Constants.Collections.users).document(userId).updateData([
                                "availableSpins": spinsToGrant,
                                "lastSpinDate": Timestamp(date: Date())
                            ])
                        }
                    } else {
                        // First time user, grant initial spins
                        let spinsToGrant = self?.userTier == "premium" ? 3 : 1
                        self?.availableSpins = spinsToGrant
                        
                        // Update in Firestore
                        self?.db.collection(Constants.Collections.users).document(userId).updateData([
                            "availableSpins": spinsToGrant,
                            "lastSpinDate": Timestamp(date: Date())
                        ])
                    }
                }
            } else {
                // Create user document if it doesn't exist
                let userData: [String: Any] = [
                    "email": Auth.auth().currentUser?.email ?? "",
                    "displayName": Auth.auth().currentUser?.displayName ?? "",
                    "notificationsEnabled": true,
                    "membershipTier": "basic",
                    "availableSpins": 1,
                    "lastSpinDate": Timestamp(date: Date()),
                    "role": "user"
                ]
                
                self?.db.collection(Constants.Collections.users).document(userId).setData(userData) { error in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else {
                        self?.userTier = "basic"
                        self?.availableSpins = 1
                    }
                }
            }
        }
    }
    
    func loadMerchantAndDeals(merchantId: String, locationId: String) {
        currentMerchantId = merchantId
        currentLocationId = locationId
        
        // Fetch merchant data
        db.collection(Constants.Collections.merchants).document(merchantId).getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if let data = snapshot?.data() {
                self?.merchantName = data["name"] as? String ?? "Casino"
            }
            
            // Now load the deals
            self?.loadDealsForLocation(merchantId: merchantId, locationId: locationId)
        }
    }
    
    func loadDealsForLocation(merchantId: String, locationId: String) {
        db.collection(Constants.Collections.deals)
            .whereField("merchantId", isEqualTo: merchantId)
            .whereField("locationIds", arrayContains: locationId)
            .whereField("active", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self?.errorMessage = "No deals available"
                    return
                }
                
                // Filter to only currently active deals
                let now = Date()
                self?.allDeals = documents.compactMap { document in
                    let deal = Deal(id: document.documentID, data: document.data())
                    return deal.isActive ? deal : nil
                }
            }
    }
    
    func spinSlots() {
        guard canSpin, !allDeals.isEmpty else { return }
        
        // Decrement available spins
        availableSpins -= 1
        updateUserSpins()
        
        // Randomize symbols
        reelSymbols = (0..<3).map { _ in symbols.randomElement()! }
        
        // Determine if win:
        // 1. All symbols match = guaranteed win
        // 2. Random 30% chance otherwise
        // 3. Premium users get 40% chance instead of 30%
        let allSymbolsMatch = Set(reelSymbols).count == 1
        let winChance = userTier == "premium" ? 0.4 : 0.3
        let randomWin = Double.random(in: 0...1) < winChance
        
        // In test mode, increase win chance to 80%
        let testModeWin = testMode && Double.random(in: 0...1) < 0.8
        
        hasWon = (allSymbolsMatch || randomWin || testModeWin) && !allDeals.isEmpty
        
        if hasWon {
            // Assign a random deal as the prize
            wonDeal = allDeals.randomElement()
        } else {
            wonDeal = nil
        }
    }
    
    func claimDeal() {
        guard let userId = userId,
              let merchantId = currentMerchantId,
              let locationId = currentLocationId,
              let deal = wonDeal else {
            errorMessage = "Could not claim deal"
            return
        }
        
        // Get current timestamp
        let now = Date()
        let validityEndTime = now.addingTimeInterval(Constants.redemptionValidityPeriod)
        
        // Create new redemption record
        let redemptionData: [String: Any] = [
            "userId": userId,
            "dealId": deal.id,
            "merchantId": merchantId,
            "locationId": locationId,
            "timestamp": Timestamp(date: now),
            "validityPeriod": Timestamp(date: validityEndTime),
            "status": Constants.RedemptionStatus.pending,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "notificationSent": true,
            "redemptionLocation": GeoPoint(latitude: 0, longitude: 0) // Default to 0,0 if location not available
        ]
        
        // Add the redemption document
        db.collection(Constants.Collections.redemptions)
            .addDocument(data: redemptionData) { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Error creating redemption: \(error.localizedDescription)"
                } else {
                    // Schedule an expiration reminder
                    NotificationManager.shared.scheduleExpirationReminder(
                        redemptionId: "", // We don't have the ID yet
                        dealTitle: deal.title,
                        expiryTime: validityEndTime
                    )
                }
            }
    }
    
    private func updateUserSpins() {
        guard let userId = userId else { return }
        
        // Don't update spins in Firestore if in test mode
        if testMode {
            return
        }
        
        db.collection(Constants.Collections.users).document(userId).updateData([
            "availableSpins": availableSpins,
            "lastSpinDate": Timestamp(date: Date())
        ])
    }
    
    func upgradeToPremuim() {
        guard let userId = userId else { return }
        
        // In test mode, just update locally
        if testMode {
            self.userTier = "premium"
            self.availableSpins = max(availableSpins, 1000)
            return
        }
        
        // Update user to premium tier
        db.collection(Constants.Collections.users).document(userId).updateData([
            "membershipTier": "premium",
            // Give them 3 spins right away
            "availableSpins": 3,
            "lastSpinDate": Timestamp(date: Date())
        ]) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.userTier = "premium"
                self?.availableSpins = 3
            }
        }
    }
}
