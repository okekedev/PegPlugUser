import SwiftUI

struct EnhancedSlotMachineView: View {
    // ViewModel
    @ObservedObject var viewModel: SlotMachineViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // State variables
    @State private var symbols = ["🍒", "🍋", "🍊", "🍇", "🔔", "💎", "7️⃣", "⭐️"]
    @State private var reels: [[String]] = [[], [], []]
    @State private var spinning = false
    @State private var spinResult: [Int] = [0, 0, 0]
    @State private var spinDurations: [Double] = [1.0, 1.3, 1.6] // Different durations for each reel
    @State private var isWinning = false
    @State private var winPulse = false
    @State private var showWinnerAlert = false
    @State private var showUpgradeAlert = false
    
    // Animation states for background
    @State private var showCoins = false
    @State private var bgPulse = false
    
    // Initialize reels with random symbols
    init(viewModel: SlotMachineViewModel) {
        self.viewModel = viewModel
        
        // Create reels
        var reelsArray: [[String]] = [[], [], []]
        for i in 0..<3 {
            reelsArray[i] = Array(repeating: "", count: 20).map { _ in symbols.randomElement()! }
        }
        _reels = State(initialValue: reelsArray)
    }
    
    var body: some View {
        ZStack {
            // Background gradient with animation
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.peg.primaryBlue.opacity(bgPulse ? 0.8 : 0.9),
                    Color.peg.primaryDarkBlue.opacity(bgPulse ? 0.9 : 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(
                Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                value: bgPulse
            )
            
            // Animated background coins
            if showCoins {
                PegCoinAnimation()
                    .opacity(0.5) // More subtle in the background
            }
            
            // Content
            VStack(spacing: 0) {
                // Header with merchant logo and close button
                HStack {
                    // Merchant info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.merchantName.isEmpty ? "Instant Peg" : viewModel.merchantName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Unlock special deals instantly")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Remaining spins indicator
                HStack {
                    Text("Remaining Spins: \(viewModel.availableSpins)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.peg.primaryBlue, Color.peg.primaryBlue.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                    
                    Spacer()
                    
                    // Upgrade button for basic members
                    if viewModel.userTier == "basic" {
                        Button(action: {
                            showUpgradeAlert = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 12))
                                Text("Upgrade")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.peg.accentGold, Color.peg.darkGold]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Explanatory text
                VStack(spacing: 4) {
                    Text("Auto-unlock a deal at a nearby location")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("No need to visit the location first!")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .padding(.vertical, 10)
                .multilineTextAlignment(.center)
                
                // Slot machine display
                VStack(spacing: 30) {
                    // Casino lights decoration
                    HStack(spacing: 6) {
                        ForEach(0..<10) { i in
                            Circle()
                                .fill(Color.peg.accentGold.opacity(0.7))
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle()
                                        .stroke(Color.peg.accentGold, lineWidth: 1)
                                )
                                .shadow(color: Color.peg.accentGold.opacity(0.5), radius: 3)
                                .opacity(isWinning ? 0.5 + 0.5 * sin(Double(i) + Date().timeIntervalSince1970 * 5) : 0.5)
                        }
                    }
                    .padding(.bottom, -10)
                    
                    // Slot machine cabinet with reels
                    ZStack {
                        // Cabinet background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "2C3E50"), Color(hex: "1A1A2E")]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.peg.accentGold, Color.peg.accentGold.opacity(0.5)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                            .frame(height: 220)
                        
                        // Reels
                        HStack(spacing: 10) {
                            ForEach(0..<3) { reelIndex in
                                ZStack {
                                    // Reel background
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.peg.accentGold, Color.peg.accentGold.opacity(0.3)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                    
                                    // Symbols
                                    Text(reels[reelIndex][spinResult[reelIndex]])
                                        .font(.system(size: 70))
                                        .scaleEffect(isWinning && winPulse ? 1.1 : 1.0)
                                        .animation(isWinning ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: winPulse)
                                }
                                .frame(width: 90, height: 120)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 50)
                        
                        // Win indicator light
                        if isWinning {
                            Circle()
                                .fill(Color.peg.primaryRed)
                                .frame(width: 15, height: 15)
                                .opacity(winPulse ? 1.0 : 0.5)
                                .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: winPulse)
                                .offset(y: -90)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Spin button and result area
                    VStack(spacing: 20) {
                        // Spin button
                        Button(action: {
                            spin()
                        }) {
                            Text("DISCOVER DEAL")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            viewModel.canSpin ? Color.peg.primaryRed : Color.gray.opacity(0.5),
                                            viewModel.canSpin ? Color.peg.primaryRed.opacity(0.8) : Color.gray.opacity(0.3)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.3)]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                                .scaleEffect(spinning ? 0.95 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: spinning)
                        }
                        .disabled(spinning || !viewModel.canSpin)
                        .opacity(spinning ? 0.8 : 1.0)
                        .padding(.horizontal, 20)
                        
                        // Upgrade tip
                        if viewModel.userTier == "basic" && viewModel.availableSpins == 0 {
                            Button(action: {
                                showUpgradeAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(Color.peg.accentGold)
                                    
                                    Text("Upgrade to Premium for more spins!")
                                        .font(.subheadline)
                                        .foregroundColor(Color.peg.accentGold)
                                }
                                .padding(.vertical, 10)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.bottom, 30)
            
            // Win overlay
            if isWinning {
                winOverlay
            }
        }
        .onAppear {
            // Initial setup
            randomizeReels()
            
            // Start background animation
            withAnimation {
                bgPulse = true
            }
            
            // Add a slight delay before showing coins for smoother loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showCoins = true
                }
            }
        }
        .onChange(of: isWinning) { newValue in
            if newValue {
                winPulse = true
                
                // Show win alert after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if viewModel.hasWon {
                        showWinnerAlert = true
                    }
                }
            }
        }
        .alert(isPresented: $showWinnerAlert) {
            Alert(
                title: Text("🎉 Deal Unlocked!"),
                message: Text("Congratulations! You've unlocked: \(viewModel.wonDeal?.title ?? "a special deal")"),
                primaryButton: .default(Text("Claim Now")) {
                    viewModel.claimDeal()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Later")) {
                    // Reset and allow another spin
                    isWinning = false
                }
            )
        }
        .alert(isPresented: $showUpgradeAlert) {
            Alert(
                title: Text("Upgrade to Premium"),
                message: Text("Get 3 instant deals daily instead of 1, plus increased winning chances!"),
                primaryButton: .default(Text("Upgrade")) {
                    viewModel.upgradeToPremuim()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Win overlay with floating coins and celebration effects
    private var winOverlay: some View {
        ZStack {
            // Particles effect
            ForEach(0..<20) { i in
                Circle()
                    .fill(Color.peg.accentGold.opacity(0.7))
                    .frame(width: CGFloat.random(in: 5...15))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -200...200)
                    )
                    .opacity(Double.random(in: 0.3...0.7))
                    .animation(
                        Animation.linear(duration: Double.random(in: 1.5...3.0))
                            .repeatForever(autoreverses: true),
                        value: isWinning
                    )
            }
            
            // Winner text
            VStack(spacing: 20) {
                Text("DEAL UNLOCKED!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.peg.primaryRed, radius: 10, x: 0, y: 0)
                    .rotationEffect(.degrees(winPulse ? 2 : -2))
                    .scaleEffect(winPulse ? 1.1 : 0.95)
                
                if let deal = viewModel.wonDeal {
                    Text(deal.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.peg.accentGold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                        .opacity(winPulse ? 1.0 : 0.8)
                }
            }
            .animation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true),
                value: winPulse
            )
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
    
    // Randomize all reels
    private func randomizeReels() {
        for i in 0..<3 {
            reels[i] = (0..<20).map { _ in symbols.randomElement()! }
        }
    }
    
    // Main spin function
    func spin() {
        guard viewModel.canSpin && !spinning else { return }
        
        // Start spinning animation
        spinning = true
        isWinning = false
        
        // Have the view model determine the outcome
        viewModel.spinSlots()
        
        // Check for win condition to set up UI
        let willWin = viewModel.hasWon
        
        // Randomize reels except for win condition
        if willWin {
            // If winning, ensure all three reels show the same symbol
            let winningSymbol = symbols.randomElement()!
            
            // Set up the reels to show matching symbols
            for i in 0..<3 {
                // Randomize most positions but ensure the final position is winning
                reels[i] = (0..<20).map { index in
                    index == 10 ? winningSymbol : symbols.randomElement()!
                }
            }
        } else {
            // For non-winning spins, ensure some symbols don't match
            randomizeReels()
            
            // Make sure final positions don't all match
            var finalSymbols = [String]()
            while finalSymbols.count < 3 {
                let symbol = symbols.randomElement()!
                if finalSymbols.count < 2 || finalSymbols[0] != symbol || finalSymbols[1] != symbol {
                    finalSymbols.append(symbol)
                }
            }
            
            // Set the final positions
            for i in 0..<3 {
                reels[i][10] = finalSymbols[i]
            }
        }
        
        // Animate each reel with slightly different timing
        for reelIndex in 0..<3 {
            // Calculate random stopping position within the array
            let stoppingPosition = 10 // Always use position 10 for consistency
            
            // Animate the spinning with staggered timing
            withAnimation(Animation.easeOut(duration: spinDurations[reelIndex])) {
                spinResult[reelIndex] = stoppingPosition
            }
        }
        
        // Reset spinning state and check for win after all reels stop
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDurations[2] + 0.5) {
            spinning = false
            
            // Set win state based on view model result
            isWinning = viewModel.hasWon
        }
    }
}
