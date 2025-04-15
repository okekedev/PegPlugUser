import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @ObservedObject var locationManager = LocationManager.shared
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    // State variables
    @State private var showingSlotMachine = false
    @State private var selectedMerchantId: String?
    @State private var selectedLocationId: String?
    @State private var selectedDealId: String?
    @State private var showDealsList = false
    @State private var showFullMap = false
    @State private var showOnboarding = false
    @State private var showOnboardingConfirmation = false
    @State private var showHelpSection = false // Toggle for help section
    
    // State for Active Pegs/Plugs sections
    @State private var selectedPegLocationId: String?
    @State private var selectedPegMerchantId: String?
    @State private var showPegDetail = false
    
    // Animation states
    @State private var appearAnimation = false
    @State private var spinCardScale: CGFloat = 0.95
    @State private var cardOpacity: Double = 0
    @State private var mapOffset: CGFloat = 50
    @State private var dealsOffset: CGFloat = 100
    
    // UserDefaults key for onboarding preference
    private let onboardingKey = "hasSeenOnboarding"
    
    // Scroll position tracker for parallax effect
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Animated background
            PegAnimationBackground(isAnimating: .constant(true))
                .opacity(0.7)
                .ignoresSafeArea()
            
            // Content
            ScrollView {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scrollView")).minY
                    )
                }
                .frame(height: 0)
                
                VStack(spacing: 20) {
                    // Header with logo and user avatar
                    HeaderView(userName: authViewModel.user?.displayName ?? "User",
                               navigateToProfile: viewModel.navigateToProfile)
                        .opacity(appearAnimation ? 1 : 0)
                    
                    // Top section with welcome and help toggle
                    HStack {
                        // Welcome message
                        Text("Welcome, \((authViewModel.user?.displayName ?? "User").components(separatedBy: " ").first ?? "User")")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                        
                        Spacer()
                        
                        // Help toggle
                        Toggle(isOn: $showHelpSection) {
                            HStack(spacing: 4) {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.white)
                                
                                Text("Help")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .toggleStyle(HelpToggleStyle())
                    }
                    .padding(.horizontal)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -10)
                    
                    // Help section (appears when toggled)
                    if showHelpSection {
                        HelpSectionView(onDismiss: {
                            withAnimation {
                                showHelpSection = false
                            }
                        })
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // App explanation card (only shown if user preference allows)
                    if showOnboarding {
                        OnboardingCard(onDismiss: {
                            withAnimation {
                                showOnboarding = false
                            }
                        })
                        .padding(.horizontal)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                    }
                    
                    // Improved simple spin card with fading emojis and no counter
                    ImprovedSimpleSpinCard(
                        onTap: {
                            if let merchant = viewModel.nearestMerchant,
                               let location = viewModel.nearestLocation {
                                selectedMerchantId = merchant.id
                                selectedLocationId = location.id
                                showingSlotMachine = true
                            }
                        }
                    )
                    .padding(.horizontal)
                    .opacity(cardOpacity)
                    .padding(.top, 5)
                    
                    // NEW: Active Pegs and Plugs Container
                    VStack(spacing: 20) {
                        // Active Pegs Section
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color.peg.primaryRed)
                                    
                                    Text("Active Pegs")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.peg.textPrimary)
                                    
                                    if !locationManager.enteredRegions.isEmpty {
                                        Circle()
                                            .fill(Color.peg.primaryRed)
                                            .frame(width: 18, height: 18)
                                            .overlay(
                                                Text("\(locationManager.enteredRegions.count)")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                .pegShimmer()
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 6, x: 0, y: 3)
                            
                            // Helper text - centered
                            Text(locationManager.enteredRegions.isEmpty ?
                                 "Visit locations to activate Pegs!" :
                                 "You're at these locations now. Tap to spin!")
                                .font(.system(size: 13))
                                .foregroundColor(Color.peg.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.7))
                            
                            // Peg list - fixed height
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    let activePegs = locationManager.enteredRegions.compactMap { regionId -> LocationWithMerchant? in
                                        if let (merchantId, locationId) = parseRegionIdentifier(regionId),
                                           let location = viewModel.locations[locationId],
                                           let merchant = viewModel.merchants[merchantId] {
                                            return LocationWithMerchant(location: location, merchant: merchant)
                                        }
                                        return nil
                                    }
                                    
                                    if activePegs.isEmpty {
                                        // Empty state
                                        VStack(spacing: 12) {
                                            Image(systemName: "mappin.slash")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color.peg.primaryRed.opacity(0.5))
                                            
                                            Text("No active pegs yet")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color.peg.textSecondary)
                                        }
                                        .frame(width: 200, height: 120)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    } else {
                                        // Active peg cards
                                        ForEach(activePegs) { pegItem in
                                            ActivePegCard(
                                                location: pegItem.location,
                                                merchant: pegItem.merchant,
                                                onTap: {
                                                    selectedPegLocationId = pegItem.location.id
                                                    selectedPegMerchantId = pegItem.merchant.id
                                                    showPegDetail = true
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                            }
                            .frame(height: 150) // Fixed height
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(16)
                            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 6, x: 0, y: 3)
                        }
                        
                        // Active Plugs Section - only show if we have active redemptions
                        if !viewModel.activeRedemptions.isEmpty {
                            VStack(spacing: 0) {
                                // Header
                                HStack {
                                    // Header text and count
                                    HStack(spacing: 8) {
                                        Image(systemName: "ticket.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(Color.peg.primaryBlue)
                                        
                                        Text("Your Active Plugs")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.peg.textPrimary)
                                        
                                        Circle()
                                            .fill(Color.peg.primaryBlue)
                                            .frame(width: 18, height: 18)
                                            .overlay(
                                                Text("\(viewModel.activeRedemptions.count)")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .pegShimmer()
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        showDealsList = true
                                    }) {
                                        HStack(spacing: 5) {
                                            Text("View All")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color.peg.primaryBlue)
                                            
                                            Image(systemName: "arrow.right.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color.peg.primaryBlue)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.peg.primaryBlue.opacity(0.1))
                                        .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 6, x: 0, y: 3)
                                
                                // Helper text - centered
                                Text("Show these to merchants to validate and redeem your deals")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.peg.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.7))
                                
                                // Active Plugs List - fixed height
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(Array(viewModel.activeRedemptions.keys), id: \.self) { dealId in
                                            if let deal = viewModel.deals.first(where: { $0.id == dealId }),
                                               let redemption = viewModel.activeRedemptions[dealId] {
                                                
                                                // Find matching merchant
                                                let merchant = viewModel.merchants[deal.merchantId]
                                                
                                                // Create enhanced plug card with validation button
                                                EnhancedPlugCard(
                                                    deal: deal,
                                                    merchant: merchant,
                                                    redemption: redemption,
                                                    onTap: {
                                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                                        generator.impactOccurred()
                                                        selectedDealId = dealId
                                                    },
                                                    onValidate: {
                                                        // This would trigger the validation flow
                                                        selectedDealId = dealId
                                                    }
                                                )
                                                .frame(width: 280)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                }
                                .frame(height: 200) // Fixed height
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(16)
                                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .offset(y: appearAnimation ? 0 : dealsOffset)
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(
                        Animation.spring(response: 0.8, dampingFraction: 0.7).delay(0.1),
                        value: appearAnimation
                    )
                    
                    // Pegs Near Me Map
                    PegsMapSection(
                        locations: viewModel.locationAnnotations,
                        onViewFullMap: { showFullMap = true },
                        onLocationTapped: { locationId, merchantId in
                            selectedLocationId = locationId
                            selectedMerchantId = merchantId
                            showingSlotMachine = true
                        }
                    )
                    .padding(.horizontal)
                    .offset(y: appearAnimation ? 0 : mapOffset)
                    .opacity(appearAnimation ? 1 : 0)
                    
                    // Quick Access Actions
                    HStack(spacing: 15) {
                        // Redemption History
                        QuickAccessButton(
                            title: "Redemption History",
                            icon: "clock.fill",
                            backgroundColor: Color.peg.primaryBlue,
                            action: {
                                // Navigate to redemption history view
                                navigateToRedemptionHistory()
                            }
                        )
                        
                        // Profile
                        QuickAccessButton(
                            title: "My Profile",
                            icon: "person.fill",
                            backgroundColor: Color.peg.primaryRed,
                            action: {
                                // Navigate to profile
                                viewModel.navigateToProfile?()
                            }
                        )
                    }
                    .padding(.horizontal)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 30)
                    
                    Spacer(minLength: 30)
                }
                .padding(.bottom, 30)
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            
            // Navigation links
            NavigationLink(
                isActive: Binding(
                    get: { selectedDealId != nil },
                    set: { if !$0 { selectedDealId = nil } }
                ),
                destination: {
                    if let dealId = selectedDealId,
                       let deal = viewModel.deals.first(where: { $0.id == dealId }) {
                        DealDetailView(deal: deal)
                    } else {
                        EmptyView()
                    }
                },
                label: { EmptyView() }
            )
            
            // Navigation to Peg Detail
            NavigationLink(
                isActive: $showPegDetail,
                destination: {
                    if let locationId = selectedPegLocationId,
                       let merchantId = selectedPegMerchantId,
                       let location = viewModel.locations[locationId],
                       let merchant = viewModel.merchants[merchantId] {
                        PegDetailView(location: location, merchant: merchant, onSpin: {
                            showingSlotMachine = true
                            selectedLocationId = locationId
                            selectedMerchantId = merchantId
                            showPegDetail = false
                        })
                    } else {
                        EmptyView()
                    }
                },
                label: { EmptyView() }
            )
            
            // Onboarding confirmation popup
            if showOnboardingConfirmation {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Allow dismissing by tapping outside
                        withAnimation {
                            showOnboardingConfirmation = false
                        }
                    }
                
                VStack(spacing: 20) {
                    Text("Show How PegPlug Works?")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Would you like to see an explanation of how PegPlug works?")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        // No button
                        Button(action: {
                            // Save preference and dismiss
                            UserDefaults.standard.set(true, forKey: onboardingKey)
                            withAnimation {
                                showOnboardingConfirmation = false
                                showOnboarding = false
                            }
                        }) {
                            Text("No, Thanks")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.peg.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.peg.fieldBackground)
                                .cornerRadius(12)
                        }
                        
                        // Yes button
                        Button(action: {
                            // Save preference and show onboarding
                            UserDefaults.standard.set(true, forKey: onboardingKey)
                            withAnimation {
                                showOnboardingConfirmation = false
                                showOnboarding = true
                            }
                        }) {
                            Text("Yes, Show Me")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.peg.primaryRed)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 4)
                .padding(.horizontal, 40)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .sheet(isPresented: $showingSlotMachine) {
            if let merchantId = selectedMerchantId,
               let locationId = selectedLocationId {
                EnhancedSlotMachineView(
                    viewModel: createSlotMachineViewModel(merchantId: merchantId, locationId: locationId)
                )
            }
        }
        .sheet(isPresented: $showDealsList) {
            DealsListView(
                viewModel: viewModel,
                selectedDealId: $selectedDealId
            )
        }
        .sheet(isPresented: $showFullMap) {
            FullMapView(
                locations: viewModel.locations,
                merchants: viewModel.merchants
            )
        }
        .onAppear {
            // Start animations
            startAnimationSequence()
            
            // Load data
            viewModel.loadUserData()
            viewModel.loadDealsAndMerchants()
            
            // Request location permissions if needed
            locationManager.requestLocationPermissionWithPrompt()
            
            // Check if user has seen onboarding before
            checkOnboardingPreference()
        }
    }
    
    private func navigateToRedemptionHistory() {
        // This is a placeholder - implement navigation to RedemptionHistoryView
        // For a non-TabView approach, you might use a custom navigation coordinator or similar
    }
    
    // Helper function to create the SlotMachineViewModel
    private func createSlotMachineViewModel(merchantId: String, locationId: String) -> SlotMachineViewModel {
        let slotViewModel = SlotMachineViewModel()
        slotViewModel.loadUserData()
        slotViewModel.loadMerchantAndDeals(merchantId: merchantId, locationId: locationId)
        return slotViewModel
    }
    
    // Animation sequence
    private func startAnimationSequence() {
        // Staggered animations for a professional feel
        withAnimation(Animation.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            appearAnimation = true
        }
        
        withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            cardOpacity = 1
            spinCardScale = 1.0
        }
    }
    
    // Helper method to parse region identifier into component IDs
    private func parseRegionIdentifier(_ identifier: String) -> (String, String)? {
        let components = identifier.split(separator: "_")
        guard components.count == 2 else { return nil }
        return (String(components[0]), String(components[1]))
    }
    
    // Check if user has seen onboarding
    private func checkOnboardingPreference() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        
        if !hasSeenOnboarding {
            // First time user, show confirmation dialog
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showOnboardingConfirmation = true
                }
            }
        } else {
            // User has made a choice before, respect that choice
            showOnboarding = false
        }
    }
}

// Help Toggle Style
struct HelpToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(spacing: 6) {
                configuration.label
                
                Image(systemName: configuration.isOn ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.peg.primaryBlue.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

// Help Section
struct HelpSectionView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header with dismiss button
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Color.peg.accentGold)
                    
                    Text("How to Use PegPlug")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.peg.textPrimary)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.peg.textSecondary)
                }
            }
            
            Divider()
            
            // Help content
            VStack(alignment: .leading, spacing: 16) {
                HelpItem(
                    icon: "mappin.circle.fill",
                    color: Color.peg.primaryRed,
                    title: "Active Pegs",
                    description: "These are locations you're currently near. Visit them to spin for deals!"
                )
                
                HelpItem(
                    icon: "ticket.fill",
                    color: Color.peg.primaryBlue,
                    title: "Active Plugs",
                    description: "Deals you've already won. Show these to merchants to redeem before they expire."
                )
                
                HelpItem(
                    icon: "mappin.and.ellipse",
                    color: Color.peg.success,
                    title: "Pegs Near Me",
                    description: "Find all participating merchants on the map and tap to get directions."
                )
                
                HelpItem(
                    icon: "dice.fill",
                    color: Color.peg.accentGold,
                    title: "Instant Peg",
                    description: "Tap to instantly spin for available deals without visiting a location."
                )
            }
            
            // Premium tip
            Text("💎 Upgrade to Premium for more daily spins and better rewards!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.peg.accentGold)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.peg.accentGold.opacity(0.1))
                .cornerRadius(8)
                .padding(.top, 5)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Help Item Component
struct HelpItem: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.peg.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color.peg.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// Active Pegs Section - NEW
struct ActivePegsSection: View {
    let locationManager: LocationManager
    let viewModel: HomeViewModel
    let onPegTapped: (String, String) -> Void
    
    var activePegs: [LocationWithMerchant] {
        // Convert entered regions to location+merchant pairs
        return locationManager.enteredRegions.compactMap { regionId in
            if let (merchantId, locationId) = parseRegionIdentifier(regionId),
               let location = viewModel.locations[locationId],
               let merchant = viewModel.merchants[merchantId] {
                return LocationWithMerchant(location: location, merchant: merchant)
            }
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.peg.primaryRed)
                    
                    Text("Active Pegs")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.peg.textPrimary)
                    
                    if !activePegs.isEmpty {
                        Circle()
                            .fill(Color.peg.primaryRed)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Text("\(activePegs.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .pegShimmer()
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 6, x: 0, y: 3)
            
            // Helper text
            HStack {
                Text(activePegs.isEmpty ? "Visit locations to activate Pegs!" : "You're at these locations now. Tap to spin!")
                    .font(.system(size: 13))
                    .foregroundColor(Color.peg.textSecondary)
                    .padding(.leading, 20)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.7))
            
            // Peg list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if activePegs.isEmpty {
                        // Empty state
                        VStack(spacing: 12) {
                            Image(systemName: "mappin.slash")
                                .font(.system(size: 30))
                                .foregroundColor(Color.peg.primaryRed.opacity(0.5))
                            
                            Text("No active pegs yet")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.peg.textSecondary)
                        }
                        .frame(width: 200, height: 120)
                        .background(Color.white)
                        .cornerRadius(12)
                    } else {
                        // Active peg cards
                        ForEach(activePegs) { pegItem in
                            ActivePegCard(
                                location: pegItem.location,
                                merchant: pegItem.merchant,
                                onTap: {
                                    onPegTapped(pegItem.location.id, pegItem.merchant.id)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.white.opacity(0.7))
            .cornerRadius(16)
            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 6, x: 0, y: 3)
        }
    }
    
    // Helper method to parse region identifier
    private func parseRegionIdentifier(_ identifier: String) -> (String, String)? {
        let components = identifier.split(separator: "_")
        guard components.count == 2 else { return nil }
        return (String(components[0]), String(components[1]))
    }
}

// Location with Merchant model for Active Pegs
struct LocationWithMerchant: Identifiable {
    let location: Location
    let merchant: Merchant
    var id: String { location.id }
}

// Active Peg Card
struct ActivePegCard: View {
    let location: Location
    let merchant: Merchant
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Status banner
                HStack {
                    Text("Active Now")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.peg.success)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Subtle pulsing dot
                    Circle()
                        .fill(Color.peg.success)
                        .frame(width: 8, height: 8)
                        .opacity(0.8)
                        .overlay(
                            Circle()
                                .fill(Color.peg.success.opacity(0.5))
                                .frame(width: 12, height: 12)
                                .opacity(0.5)
                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
                        )
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Divider()
                    .padding(.horizontal)
                
                // Merchant & location info
                HStack(spacing: 12) {
                    // Merchant logo/icon
                    ZStack {
                        Circle()
                            .fill(Color.peg.primaryRed.opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Text(merchant.name.prefix(1).uppercased())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.peg.primaryRed)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 3) {
                        Text(merchant.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.peg.textPrimary)
                        
                        Text(location.name)
                            .font(.caption)
                            .foregroundColor(Color.peg.textSecondary)
                        
                        // "Spin Now" hint with icon
                        HStack(spacing: 3) {
                            Image(systemName: "dice.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.peg.accentGold)
                            
                            Text("Tap to Spin Now")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color.peg.accentGold)
                        }
                        .padding(.top, 3)
                    }
                }
                .padding(12)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
            .frame(width: 220, height: 130)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Peg Detail View - shown when tapping an active peg
struct PegDetailView: View {
    let location: Location
    let merchant: Merchant
    let onSpin: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with merchant info
                HStack(spacing: 14) {
                    // Merchant logo/icon
                    ZStack {
                        Circle()
                            .fill(Color.peg.primaryRed.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Text(merchant.name.prefix(1).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.peg.primaryRed)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(merchant.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.peg.textPrimary)
                        
                        Text(location.name)
                            .font(.subheadline)
                            .foregroundColor(Color.peg.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Active peg status
                VStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.peg.success.opacity(0.2))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color.peg.success)
                    }
                    
                    // Status text
                    Text("You're Currently Here!")
                        .font(.headline)
                        .foregroundColor(Color.peg.success)
                    
                    Text("This Peg is active and ready for you to claim exclusive deals!")
                        .font(.subheadline)
                        .foregroundColor(Color.peg.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.peg.success.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Location address
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Color.peg.textPrimary)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(Color.peg.primaryRed)
                        
                        Text(location.address)
                            .font(.subheadline)
                            .foregroundColor(Color.peg.textSecondary)
                    }
                    
                    // Map link
                    Button(action: {
                        // Open Apple Maps with directions
                        let coordinate = location.coordinate
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                        mapItem.name = location.name
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Get Directions")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.peg.primaryBlue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.peg.primaryBlue.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding(.top, 6)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Spin now button
                Button(action: onSpin) {
                    HStack {
                        Image(systemName: "dice.fill")
                            .font(.title3)
                        
                        Text("SPIN NOW")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.peg.accentGold, Color.peg.darkGold]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.peg.accentGold.opacity(0.4), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .background(Color.peg.background)
        .navigationTitle("Active Peg")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Scroll offset preference key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
