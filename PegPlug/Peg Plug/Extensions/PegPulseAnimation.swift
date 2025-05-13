//
//  PegPulseAnimation.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI

// MARK: - Animation Components

// MARK: - Pulse Animation
struct PegPulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 1.0 : 0.7)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Fade In Animation
struct PegFadeIn: ViewModifier {
    @State private var opacity: Double = 0
    let delay: Double
    
    init(delay: Double = 0) {
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn.delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Slide In Animation
struct PegSlideIn: ViewModifier {
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    let delay: Double
    let direction: Edge
    
    init(direction: Edge = .bottom, delay: Double = 0) {
        self.direction = direction
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(
                x: direction == .leading ? offset : (direction == .trailing ? -offset : 0),
                y: direction == .top ? offset : (direction == .bottom ? -offset : 0)
            )
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    opacity = 1
                    offset = 0
                }
            }
    }
}

// MARK: - Shimmer Effect
struct PegShimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Color.white
                        .opacity(0.3)
                        .mask(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .clear, location: phase - 0.2),
                                            .init(color: .white, location: phase),
                                            .init(color: .clear, location: phase + 0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: geometry.size.width * 3)
                                .rotationEffect(.degrees(70))
                                .offset(x: -geometry.size.width * 1.5 + geometry.size.width * 3 * phase)
                        )
                }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Loading Animation
struct PegLoadingAnimation: View {
    @State private var isAnimating = false
    let color: Color
    
    init(color: Color = Color.peg.primaryRed) {
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(0.2 * Double(index)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Logo Component

// PEG Logo Component with animations
struct PegLogo: View {
    @State private var glowOpacity: Double = 0.0
    @State private var rotationAmount: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background glow effect
            Circle()
                .fill(Color.peg.primaryRed)
                .frame(width: 100, height: 100)
                .blur(radius: 20)
                .opacity(glowOpacity)
            
            // Logo container
            ZStack {
                // Background rounded rect
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.peg.backgroundGradient())
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                
                // Pin with globe
                ZStack {
                    // Pin background
                    Circle()
                        .fill(Color.peg.primaryRed)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                    
                    // Globe icon
                    Image(systemName: "globe")
                        .font(.system(size: 30, weight: .regular))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAmount))
                    
                    // Sparkles
                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .offset(x: 15, y: -15)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .offset(x: -18, y: 15)
                }
                
                // PEG text at bottom
                Text("PEG")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: 40)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
            
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAmount = 360
            }
        }
    }
}

// MARK: - Location Logo Component
struct PegLocationLogo: View {
    // Animation state
    @State private var glowAmount: CGFloat = 1.0
    @State private var rotationAmount: Double = 0
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(Color.peg.primaryRed.opacity(0.3))
                .frame(width: 110, height: 110)
                .blur(radius: 15)
                .opacity(glowAmount)
            
            // App logo - using a system image
            Image(systemName: "mappin.and.ellipse.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(Color.peg.primaryRed)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 90, height: 90)
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .rotationEffect(.degrees(rotationAmount))
        }
        .onAppear {
            // Start subtle pulsing animation
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowAmount = 0.7
            }
            
            // Slow continuous rotation
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAmount = 360
            }
        }
    }
}

// MARK: - Coin Animation Components
// Add the PegCoin Animation from your file

// MARK: - Coin Data Model
struct CoinModel: Identifiable {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    var rotation: Double
    let horizontalSpeed: CGFloat
    let verticalSpeed: CGFloat
    let rotationSpeed: Double
    var showsFront: Bool
    let flipInterval: TimeInterval
    var lastFlipTime: Date
    let opacity: Double
}

// MARK: - Individual Coin View
struct PegCoin: View {
    let size: CGFloat
    let rotation: Double
    let isFrontSide: Bool
    let flipDuration: Double
    
    var body: some View {
        ZStack {
            // Base coin circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "FFD700"), // Gold
                            Color(hex: "F1C232"), // Lighter gold
                            Color(hex: "DFB140"), // Darker gold
                            Color(hex: "F1C232")  // Back to lighter gold
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 2, y: 2)
            
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "DFB140").opacity(0.8),
                            Color(hex: "FFD700").opacity(0.9),
                            Color(hex: "F1C232").opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size / 20
                )
                .frame(width: size, height: size)
            
            // Content for front or back
            if isFrontSide {
                // Front side with "PEG" text
                frontSideContent(size: size, rotation: rotation)
            } else {
                // Back side with "PLUG" text
                backSideContent(size: size, rotation: rotation)
            }
            
            // Edge detailing
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color(hex: "DFB140").opacity(0.6))
                    .frame(width: 1, height: size * 0.1)
                    .offset(y: size * 0.45)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
        .rotationEffect(.degrees(rotation))
        .rotation3DEffect(
            .degrees(isFrontSide ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(response: flipDuration, dampingFraction: 0.7), value: isFrontSide)
    }
    
    // Front side content
    private func frontSideContent(size: CGFloat, rotation: Double) -> some View {
        Text("PEG")
            .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
            .foregroundColor(Color(hex: "8B5A00").opacity(0.8)) // Dark gold text
            .rotationEffect(.degrees(-rotation)) // Counter-rotate to keep text upright
    }
    
    // Back side content - reversed text to appear correctly when flipped
    private func backSideContent(size: CGFloat, rotation: Double) -> some View {
        Text("Plug") // Updated to use "Plug" instead of "GULP"
            .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
            .foregroundColor(Color(hex: "8B5A00").opacity(0.8)) // Dark gold text
            .rotationEffect(.degrees(-rotation)) // Counter-rotate to keep text upright
            .scaleEffect(x: -1, y: 1, anchor: .center) // Flip the text horizontally
    }
}

// MARK: - PegCoin Animation
struct PegCoinAnimation: View {
    @State private var coins: [CoinModel] = []
    
    // Coin settings
    let numberOfCoins = 12
    let minSize: CGFloat = 40
    let maxSize: CGFloat = 70
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Coins
                ForEach(coins) { coin in
                    PegCoin(
                        size: coin.size,
                        rotation: coin.rotation,
                        isFrontSide: coin.showsFront,
                        flipDuration: 0.6 // Consistent flip duration for all coins
                    )
                    .position(coin.position)
                }
            }
            .onAppear {
                initializeCoins(in: geometry.size)
                startCoinAnimations()
            }
        }
    }
    
    private func initializeCoins(in size: CGSize) {
        // Create random coins distributed throughout the entire screen
        coins = (0..<numberOfCoins).map { _ in
            // Generate random position across the entire screen
            let position = CGPoint(
                x: CGFloat.random(in: 20...(size.width - 20)),
                y: CGFloat.random(in: 0...(size.height - 20))
            )
            
            return CoinModel(
                id: UUID(),
                position: position,
                size: CGFloat.random(in: minSize...maxSize),
                rotation: Double.random(in: 0...360),
                horizontalSpeed: CGFloat.random(in: -1.0...1.0),
                verticalSpeed: CGFloat.random(in: -1.0...1.0),
                rotationSpeed: 1.0, // Fixed rotation speed for all coins
                showsFront: Bool.random(),
                flipInterval: Double.random(in: 3...8),
                lastFlipTime: Date(),
                opacity: Double.random(in: 0.7...0.95)
            )
        }
    }
    
    private func startCoinAnimations() {
        // Set up animations for each coin individually
        for i in 0..<coins.count {
            animateCoin(index: i)
        }
    }
    
    private func animateCoin(index: Int) {
        guard index < coins.count else { return }
        
        func createNewAnimation() {
            // Choose a completely new random position anywhere on screen
            let newPosition = CGPoint(
                x: CGFloat.random(in: 20...(UIScreen.main.bounds.width - 20)),
                y: CGFloat.random(in: 0...(UIScreen.main.bounds.height - 20))
            )
            
            // Always use animation to move to avoid sudden position resets
            SwiftUI.withAnimation(Animation.easeInOut(duration: Double.random(in: 5...10))) {
                coins[index].position = newPosition
            }
            
            // Schedule the next animation after this one completes
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 8...12)) {
                createNewAnimation()
            }
        }
        
        // Start the animation chain
        createNewAnimation()
        
        // Create a rotation animation - using a more controlled, consistent rotation speed
        SwiftUI.withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
            // Use a fixed rotation increment instead of variable speed to avoid sudden quick rotations
            coins[index].rotation += 360
        }
        
        // Set up coin flipping at random intervals (but consistent flip speed)
        // The timing of flips is random, but the animation speed of each flip is consistent
        func scheduleNextFlip() {
            // Random time until next flip (3-8 seconds)
            let nextFlipDelay = Double.random(in: 3...8)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + nextFlipDelay) {
                // Flip the coin with consistent animation speed
                SwiftUI.withAnimation {
                    coins[index].showsFront.toggle()
                }
                
                // Schedule the next flip
                scheduleNextFlip()
            }
        }
        
        // Start the flipping sequence
        scheduleNextFlip()
    }
}

// MARK: - Animated Background
struct PegAnimationBackground: View {
    @Binding var isAnimating: Bool
    
    @State private var phase = 0.0
    @State private var bubbles = [BubbleModel]()
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init(isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        
        // Initialize bubbles
        var initialBubbles = [BubbleModel]()
        for _ in 0..<15 {
            initialBubbles.append(BubbleModel.random())
        }
        self._bubbles = State(initialValue: initialBubbles)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            Rectangle()
                .fill(Color.peg.backgroundGradient())
                .ignoresSafeArea()
            
            // Animated wave pattern
            ZStack {
                // First wave
                Wave(phase: phase, amplitude: 30, frequency: 0.2)
                    .fill(Color.white.opacity(0.1))
                    .ignoresSafeArea()
                
                // Second wave
                Wave(phase: phase + 0.5, amplitude: 40, frequency: 0.3)
                    .fill(Color.white.opacity(0.08))
                    .ignoresSafeArea()
            }
            
            // Animated bubbles
            ForEach(bubbles) { bubble in
                Circle()
                    .fill(Color.white.opacity(bubble.opacity))
                    .frame(width: bubble.size, height: bubble.size)
                    .position(bubble.position)
                    .blur(radius: bubble.blur)
            }
        }
        .onReceive(timer) { _ in
            if isAnimating {
                // Update wave phase
                withAnimation(.linear(duration: 0.1)) {
                    phase += 0.01
                }
                
                // Update bubble positions
                withAnimation(.linear(duration: 0.1)) {
                    for i in 0..<bubbles.count {
                        var updatedBubble = bubbles[i]
                        updatedBubble.position.y -= updatedBubble.speed
                        
                        // Reset bubble if it moves off screen
                        if updatedBubble.position.y < -100 {
                            updatedBubble = BubbleModel.random()
                            updatedBubble.position.y = UIScreen.main.bounds.height + 50
                        }
                        
                        bubbles[i] = updatedBubble
                    }
                }
            }
        }
    }
    
    // Wave shape for animated background
    struct Wave: Shape {
        var phase: Double
        var amplitude: Double
        var frequency: Double
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            // Move to the bottom left corner
            path.move(to: CGPoint(x: 0, y: rect.height))
            
            // Draw the wave
            for x in stride(from: 0, through: rect.width, by: 1) {
                let relativeX = x / rect.width
                let sine = sin(relativeX * .pi * frequency * 8 + phase)
                let y = amplitude * sine + rect.height * 0.8
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Complete the path by connecting to the bottom right and back to bottom left
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
            
            return path
        }
        
        var animatableData: Double {
            get { phase }
            set { phase = newValue }
        }
    }
    
    // Bubble model for animation
    struct BubbleModel: Identifiable {
        let id = UUID()
        var position: CGPoint
        var size: CGFloat
        var opacity: Double
        var speed: CGFloat
        var blur: CGFloat
        
        static func random() -> BubbleModel {
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            return BubbleModel(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: 0...screenHeight)
                ),
                size: CGFloat.random(in: 5...40),
                opacity: Double.random(in: 0.05...0.3),
                speed: CGFloat.random(in: 0.5...2.0),
                blur: CGFloat.random(in: 0...4)
            )
        }
    }
}

// MARK: - Animation Extensions
extension View {
    // Apply subtle pulse animation
    func pegPulse() -> some View {
        modifier(PegPulseAnimation())
    }
    
    // Apply fade in animation
    func pegFadeIn(delay: Double = 0) -> some View {
        modifier(PegFadeIn(delay: delay))
    }
    
    // Apply slide in animation
    func pegSlideIn(from direction: Edge = .bottom, delay: Double = 0) -> some View {
        modifier(PegSlideIn(direction: direction, delay: delay))
    }
    
    // Apply shimmer effect
    func pegShimmer() -> some View {
        modifier(PegShimmer())
    }
}