import SwiftUI

struct HeaderView: View {
    // MARK: - Properties
    let userName: String
    let navigateToProfile: (() -> Void)?
    
    // State for animations
    @State private var isLogoAnimating = false
    @State private var showWelcome = false
    @State private var notificationCount: Int = 2 // Replace with actual notification count
    
    // Environment values for dynamic sizing
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Main header row with logo and controls
            HStack(alignment: .center) {
                // Brand mark
                brandLogo
                
                Spacer()
                
                // Controls
                HStack(spacing: 16) {
                    // Notifications button
                    notificationButton
                    
                    // Profile button
                    profileButton
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
          
            
            
        }
        .onAppear {
            // Staggered animations
            withAnimation(.easeOut(duration: 0.6)) {
                isLogoAnimating = true
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showWelcome = true
            }
        }
    }
    
    // MARK: - UI Components
    
    // Brand logo with subtle glow effect
    private var brandLogo: some View {
        HStack(spacing: 8) {
            // Icon component
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color.peg.primaryRed.opacity(0.3))
                    .frame(width: 46, height: 46)
                    .blur(radius: 8)
                    .opacity(isLogoAnimating ? 0.7 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isLogoAnimating
                    )
                
                // Logo icon
                Image(systemName: "mappin.and.ellipse.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color.peg.primaryRed)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
            // Brand name
            Text("PegPlug")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.peg.primaryRed)
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.clear,
                        radius: 1, x: 0, y: 1)
        }
    }
    
    // Notification button with badge
    private var notificationButton: some View {
        Button(action: {
            // Handle notification tap
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
        }) {
            ZStack(alignment: .topTrailing) {
                // Button background
                Circle()
                    .fill(colorScheme == .dark ?
                          Color.black.opacity(0.3) :
                          Color.peg.fieldBackground)
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.peg.shadow.opacity(0.1),
                            radius: 2, x: 0, y: 1)
                
                // Bell icon
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.peg.textSecondary)
                    .frame(width: 40, height: 40)
                
                // Notification badge
                if notificationCount > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.peg.primaryRed)
                            .frame(width: 18, height: 18)
                        
                        Text("\(min(notificationCount, 9))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: -4)
                }
            }
        }
    }
    
    // Profile button with avatar
    private var profileButton: some View {
        Button(action: {
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            navigateToProfile?()
        }) {
            ZStack {
                // Button container
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
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.peg.shadow.opacity(0.2),
                            radius: 3, x: 0, y: 2)
                
                // User initial
                Text(userName.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
        }
    }
    

    
    // MARK: - Helper Properties
    
    // Extract first name
    private var firstName: String {
        return userName.components(separatedBy: " ").first ?? userName
    }
    
    // Time-aware greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
}

// MARK: - Preview
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode
            HeaderView(userName: "Christian Okeke", navigateToProfile: nil)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.peg.background)
            
            // Dark mode
            HeaderView(userName: "Christian Okeke", navigateToProfile: nil)
                .previewLayout(.sizeThatFits)
                .padding()
                .background(Color.black)
                .colorScheme(.dark)
        }
    }
}
