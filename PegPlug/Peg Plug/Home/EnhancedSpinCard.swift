import SwiftUI

struct ImprovedSimpleSpinCard: View {
    let onTap: () -> Void
    
    // For emoji management
    @State private var currentEmoji = "🎰"
    @State private var nextEmoji = "💰"
    @State private var emojiOpacity = 1.0
    @State private var nextChangeTime = Date()
    
    // Limited animation states
    @State private var isPressed = false
    @State private var showGlow = false
    
    // Emoji collection - can be easily modified
    private let emojis = ["🎰", "💰", "🎁", "🎲", "💎", "🎯", "🎪", "🎨", "🎭", "🎟️"]
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Simple press animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Reset and execute
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    isPressed = false
                }
                onTap()
            }
        }) {
            ZStack {
                // Base card with simple gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.peg.primaryBlue,
                                Color.peg.primaryDarkBlue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Simple pulsing glow
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .blur(radius: 12)
                            .opacity(showGlow ? 0.15 : 0.05)
                    )
                    .overlay(
                        // Simple border
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Content with emoji and text
                HStack(spacing: 24) {
                    // Emoji container with fading transition
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        // Current emoji that fades out
                        Text(currentEmoji)
                            .font(.system(size: 40))
                            .opacity(emojiOpacity)
                        
                        // Next emoji that fades in
                        Text(nextEmoji)
                            .font(.system(size: 40))
                            .opacity(1.0 - emojiOpacity)
                    }
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Spin")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Tap to win exclusive deals")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Simple arrow
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 120)
        .onAppear {
            // Start the subtle animations
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                showGlow = true
            }
            
            // Start emoji changing timer
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                updateEmoji()
            }
        }
    }
    
    // Changes emoji with fade transition at random intervals
    private func updateEmoji() {
        let now = Date()
        
        // Check if it's time to change or in the middle of changing
        if now >= nextChangeTime && emojiOpacity == 1.0 {
            // Start fade out transition
            withAnimation(.easeInOut(duration: 0.2)) {
                emojiOpacity = 0.0
            }
            
            // Pick a new emoji for next (different from current)
            var newEmoji: String
            repeat {
                newEmoji = emojis.randomElement() ?? "🎰"
            } while newEmoji == nextEmoji
            
            // Schedule the change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Swap emojis
                currentEmoji = nextEmoji
                nextEmoji = newEmoji
                
                // Start fade back in
                withAnimation(.easeInOut(duration: 0.2)) {
                    emojiOpacity = 1.0
                }
                
                // Set next change time to a random interval (2-5 seconds)
                let randomInterval = Double.random(in: 5.0...5.0)
                nextChangeTime = now.addingTimeInterval(randomInterval)
            }
        }
    }
}

// MARK: - Preview
struct ImprovedSimpleSpinCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.peg.background
                .ignoresSafeArea()
            
            ImprovedSimpleSpinCard() {
                print("Card tapped")
            }
            .padding(.horizontal)
        }
    }
}
