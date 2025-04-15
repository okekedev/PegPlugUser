import SwiftUI

// MARK: - Peg Animation Components

// Animated validation check mark
struct ValidationCheckmark: View {
    @State private var animateCheck = false
    @State private var animateCircle = false
    
    var body: some View {
        ZStack {
            // Background circle that grows
            Circle()
                .trim(from: 0, to: animateCircle ? 1 : 0)
                .stroke(Color.peg.success, lineWidth: 2)
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(-90))
                .animation(
                    Animation.easeOut(duration: 0.6).delay(0.2),
                    value: animateCircle
                )
            
            // Checkmark that draws itself
            Path { path in
                path.move(to: CGPoint(x: 10, y: 17))
                path.addLine(to: CGPoint(x: 15, y: 22))
                path.addLine(to: CGPoint(x: 24, y: 12))
            }
            .trim(from: 0, to: animateCheck ? 1 : 0)
            .stroke(Color.peg.success, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .animation(
                Animation.easeOut(duration: 0.4).delay(0.6),
                value: animateCheck
            )
        }
        .onAppear {
            // Start animations when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateCircle = true
                animateCheck = true
            }
        }
    }
}

// Animated Peg Location Pin
struct AnimatedPegPin: View {
    @State private var pulsate = false
    @State private var rotate = false
    let color: Color
    
    init(color: Color = Color.peg.primaryRed) {
        self.color = color
    }
    
    var body: some View {
        ZStack {
            // Outer pulse effect
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: pulsate ? 48 : 36)
                .opacity(pulsate ? 0 : 0.6)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: pulsate
                )
            
            // Pin circle
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    ZStack {
                        // Inner highlight
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 16, height: 16)
                            .offset(x: -5, y: -5)
                        
                        // "P" logo
                        Text("P")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotate ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 8)
                                    .repeatForever(autoreverses: false),
                                value: rotate
                            )
                    }
                )
                .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
            
            // Pin point
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 12))
                .foregroundColor(color)
                .offset(y: 20)
        }
        .onAppear {
            // Start animations
            pulsate = true
            rotate = true
        }
    }
}

// Timer countdown animation
struct CountdownTimer: View {
    let remainingTime: TimeInterval
    let totalTime: TimeInterval
    
    @State private var isAnimating = false
    
    var progress: Double {
        return min(1.0, max(0.0, remainingTime / totalTime))
    }
    
    var timerColor: Color {
        if progress < 0.25 {
            return Color.peg.error
        } else if progress < 0.5 {
            return Color.peg.warning
        } else {
            return Color.peg.success
        }
    }
    
    var formattedTime: String {
        if remainingTime <= 0 {
            return "Expired"
        }
        
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                .frame(width: 50, height: 50)
            
            // Progress arc with animation
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    timerColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: progress)
            
            // Time text
            VStack(spacing: 0) {
                Text(formattedTime)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(timerColor)
                    .scaleEffect(isAnimating && progress < 0.25 ? 1.1 : 1.0)
            }
        }
        .onAppear {
            // Start subtle animation for low time warning
            if progress < 0.25 {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
        .onChange(of: progress) { newValue in
            if newValue < 0.25 && !isAnimating {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            } else if newValue >= 0.25 && isAnimating {
                isAnimating = false
            }
        }
    }
}

// Animated validation button
struct ValidateButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Trigger press animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Reset after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring()) {
                    isPressed = false
                }
                // Execute the action
                action()
            }
        }) {
            HStack {
                Spacer()
                
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 16))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.peg.success)
                
                Text("Validate")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // Subtle gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.peg.success,
                            Color.peg.success.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Animated shimmer effect
                    GeometryReader { geometry in
                        Color.white
                            .opacity(0.2)
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .clear, location: 0.35),
                                                .init(color: .white, location: 0.5),
                                                .init(color: .clear, location: 0.65)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * 0.6)
                                    .offset(x: -geometry.size.width * 0.9 + geometry.size.width * 2 * 0.6)
                                    .animation(
                                        Animation.linear(duration: 2.0)
                                            .repeatForever(autoreverses: false)
                                            .delay(1),
                                        value: UUID()
                                    )
                            )
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.peg.success.opacity(0.4), radius: 4, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// Animated location marker that shows when near a Peg
struct NearbyPegMarker: View {
    @State private var outerPulse = false
    @State private var innerPulse = false
    @State private var rotate = false
    
    let locationName: String
    let distance: String
    
    var body: some View {
        VStack {
            ZStack {
                // Animated marker
                ZStack {
                    // Background pulse
                    Circle()
                        .fill(Color.peg.primaryRed.opacity(0.3))
                        .frame(width: outerPulse ? 60 : 45)
                        .opacity(outerPulse ? 0 : 0.7)
                    
                    // Middle pulse
                    Circle()
                        .fill(Color.peg.primaryRed.opacity(0.5))
                        .frame(width: innerPulse ? 45 : 35)
                        .opacity(innerPulse ? 0.3 : 0.8)
                    
                    // Main pin circle
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.peg.primaryRed,
                                    Color.peg.primaryRed.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("P")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(rotate ? 360 : 0))
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                
                // Location info card
                VStack(spacing: 2) {
                    Text(locationName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.peg.textPrimary)
                    
                    Text(distance)
                        .font(.system(size: 12))
                        .foregroundColor(Color.peg.primaryRed)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.peg.shadow.opacity(0.2), radius: 3, x: 0, y: 2)
                .offset(y: 45)
            }
        }
        .frame(height: 100)
        .onAppear {
            // Start animations when view appears
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                outerPulse = true
            }
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.5)) {
                innerPulse = true
            }
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotate = true
            }
        }
    }
}

// Animated plugs showcase
struct PlugsShowcase: View {
    let deals: [Deal]
    let merchants: [String: Merchant]
    
    @State private var currentIndex = 0
    @State private var appearing = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            Text("Popular Deals")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color.peg.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Showcase carousel with animation
            ZStack {
                // Only show 3 deals max at a time
                ForEach(0..<min(3, deals.count), id: \.self) { index in
                    // Calculate the visible index based on the current position
                    let visibleIndex = (currentIndex + index) % deals.count
                    let deal = deals[visibleIndex]
                    let merchant = merchants[deal.merchantId]
                    
                    // Card with offset and scale based on position
                    HStack {
                        // Deal image
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.peg.primaryBlue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                AsyncImage(url: URL(string: deal.imageUrl)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        Image(systemName: "tag.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color.peg.primaryBlue)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            )
                        
                        // Deal info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(deal.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.peg.textPrimary)
                                .lineLimit(1)
                            
                            Text(merchant?.name ?? "Unknown Merchant")
                                .font(.caption)
                                .foregroundColor(Color.peg.textSecondary)
                                .lineLimit(1)
                            
                            // Tags or categories
                            Text("Limited Time")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.peg.accentGold)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.peg.shadow.opacity(0.15), radius: 8, x: 0, y: 4)
                    .opacity(index == 0 ? 1 : 0.7 - 0.2 * Double(index))
                    .scaleEffect(index == 0 ? 1 : 0.9 - 0.05 * Double(index), anchor: .center)
                    .offset(y: CGFloat(index * 8))
                    .animation(.spring(), value: currentIndex)
                    .animation(.spring(), value: appearing)
                }
            }
            .frame(height: 120)
            .padding(.top, 8)
            
            // Navigation dots
            if deals.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<deals.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.peg.primaryBlue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                            .animation(.spring(), value: currentIndex)
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            // Start appearing animation
            withAnimation(.easeOut(duration: 0.5)) {
                appearing = true
            }
            
            // Auto-advance timer
            startAutoAdvanceTimer()
        }
    }
    
    // Auto-advance timer
    private func startAutoAdvanceTimer() {
        guard deals.count > 1 else { return }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            withAnimation {
                currentIndex = (currentIndex + 1) % deals.count
            }
        }
    }
}

// Peg bounce animation when tap occurs
struct PegTapAnimation: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Ripple effect
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color.peg.primaryRed.opacity(0.5 - Double(i) * 0.15), lineWidth: 2)
                    .scaleEffect(isAnimating ? 1 + CGFloat(i) * 0.5 : 0)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 0.8)
                            .delay(Double(i) * 0.15),
                        value: isAnimating
                    )
            }
            
            // Center icon
            Image(systemName: "mappin.and.ellipse.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.peg.primaryRed)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(
                    Animation.spring(response: 0.4, dampingFraction: 0.6),
                    value: isAnimating
                )
        }
        .frame(width: 80, height: 80)
    }
}
