//
//  PegColorTheme.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI

// MARK: - Peg Color System
// Base color extension with 'peg' namespace
extension Color {
    static let peg = PegColorTheme()
    
    // Helper to create colors from hex values
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Main color theme structure
struct PegColorTheme {
    // MARK: - Brand Colors
    
    // Primary colors from the login screen
    let primaryRed = Color(hex: "FF4954")          // Main red accent from pin/buttons
    let primaryBlue = Color(hex: "25C4F3")         // Bright blue from background gradient
    let primaryDarkBlue = Color(hex: "0093E0")     // Darker blue from background gradient
    
    // Gold accents used in various places
    let accentGold = Color(hex: "F1C232")          // Main gold for buttons
    let darkGold = Color(hex: "DFB140")            // Darker gold for shadows/buttons
    let lightGold = Color(hex: "FFD700")           // Light gold for highlights
    
    // MARK: - Background Colors
    
    // Main app backgrounds
    let background = Color.white                   // Clean background
    let cardBackground = Color.white               // Card background
    let darkBackground = Color(hex: "1A1A2E")      // Dark background for modals/games
    
    // Gradient components
    let backgroundGradientTop = Color(hex: "25C4F3")     // Top of background gradient
    let backgroundGradientBottom = Color(hex: "0075BA")  // Bottom of background gradient
    
    // MARK: - Text Colors
    
    // Text hierarchy
    let textPrimary = Color(hex: "212121")         // Primary text color
    let textSecondary = Color(hex: "757575")       // Secondary/subtitle text
    let textOnDark = Color.white                   // Text on dark backgrounds
    
    // MARK: - UI Element Colors
    
    // Input fields
    let fieldBackground = Color(hex: "F5F8FA")     // Background for text fields
    let border = Color(hex: "D8E3E7")              // Border color for inputs
    let shadow = Color(hex: "1A73E8").opacity(0.15) // Shadow color
    
    // Status colors
    let success = Color(hex: "34C759")             // Success indicators
    let warning = Color(hex: "FF9500")             // Warning indicators
    let error = Color(hex: "FF3B30")               // Error indicators
    
    // MARK: - Gradients
    
    // Helper methods to create consistent gradients
    func buttonGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryRed, primaryRed.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func backgroundGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [backgroundGradientTop, backgroundGradientBottom]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    func goldGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [lightGold, accentGold, darkGold]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Text Style Extensions
extension Text {
    func pegHeading1() -> Text {
        self.font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(Color.peg.textPrimary)
    }
    
    func pegHeading2() -> Text {
        self.font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundColor(Color.peg.textPrimary)
    }
    
    func pegBody() -> Text {
        self.font(.system(size: 16, weight: .regular))
            .foregroundColor(Color.peg.textPrimary)
    }
    
    func pegCaption() -> Text {
        self.font(.system(size: 12, weight: .regular))
            .foregroundColor(Color.peg.textSecondary)
    }
    
    func pegOnDark() -> Text {
        self.foregroundColor(.white)
    }
}

// MARK: - Standard Text Field Styles
struct PegTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.peg.fieldBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.peg.border, lineWidth: 1)
            )
            .shadow(color: Color.peg.shadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Glass UI Styles
struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .opacity(0.05)
                            .blur(radius: 10)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .foregroundColor(.white)
            .accentColor(.white)
    }
}

// Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    var foregroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .opacity(0.05)
                            .blur(radius: 10)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.white)
                            .opacity(0.05)
                            .blur(radius: 10)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}

// MARK: - Standard Button Styles
struct PegButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 16)
            .background(
                configuration.isPressed ?
                Color.peg.primaryRed.opacity(0.8) :
                Color.peg.primaryRed
            )
            .cornerRadius(12)
            .shadow(color: configuration.isPressed ? 
                Color.peg.shadow.opacity(0.1) : 
                Color.peg.shadow.opacity(0.3),
                radius: configuration.isPressed ? 2 : 4,
                x: 0,
                y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Secondary Button Style
struct PegSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.peg.primaryBlue, lineWidth: 2)
            )
            .foregroundColor(Color.peg.primaryBlue)
            .shadow(color: Color.peg.shadow.opacity(0.2), radius: 3, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Gold Button Style
struct PegGoldButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.peg.accentGold, Color.peg.darkGold]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8)
            .scaleEffect(configuration.isPressed || isLoading ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Card Styles
struct PegCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.peg.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.peg.shadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Toggle Style
struct PegToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color.peg.primaryBlue : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 26, height: 26)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

// MARK: - Floating Action Button
struct PegFloatingActionButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.peg.primaryRed)
                .cornerRadius(30)
                .shadow(color: Color.peg.shadow.opacity(0.4), radius: 5, x: 0, y: 3)
        }
    }
}

// MARK: - Tab Style
struct PegTabStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accentColor(Color.peg.primaryRed)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.peg.textSecondary)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.peg.textSecondary)]
                
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.peg.primaryRed)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.peg.primaryRed)]
                
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
    }
}

// MARK: - Navigation Helpers
// Function to apply consistent navigation bar appearance
func configurePegNavigationBar() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(Color.peg.backgroundGradientTop)
    appearance.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
    ]
    appearance.largeTitleTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold)
    ]
    
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().tintColor = .white
}

// MARK: - Common View Extensions
extension View {
    // Apply peg standard shadow to elements
    func pegShadow(radius: CGFloat = 5, y: CGFloat = 3) -> some View {
        self.shadow(color: Color.peg.shadow, radius: radius, x: 0, y: y)
    }
    
    // Apply a gradient background to the view
    func pegGradientBackground() -> some View {
        self.background(Color.peg.backgroundGradient())
    }
    
    // Apply a standard card style
    func pegCardStyle() -> some View {
        self
            .background(Color.peg.cardBackground)
            .cornerRadius(16)
            .pegShadow()
    }
    
    // Apply tab styling
    func pegTabStyle() -> some View {
        modifier(PegTabStyle())
    }
    
    // Apply glass card style
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
    
    // Apply card style
    func pegCard() -> some View {
        modifier(PegCard())
    }
}

// MARK: - Legacy Theme Support
// If your app was originally using 'Color.theme', this provides a fallback
extension Color {
    static let theme = LegacyColorTheme()
}

// Legacy support structure that maps to the new colors
struct LegacyColorTheme {
    let primary = Color.peg.primaryRed
    let primaryDark = Color.peg.primaryDarkBlue
    let secondary = Color.peg.primaryBlue
    let tertiary = Color.peg.success
    
    let background = Color.peg.background
    let foreground = Color.peg.textPrimary
    let cardBg = Color.peg.cardBackground
    let panelBg = Color.peg.fieldBackground
    let borderColor = Color.peg.border
    
    let success = Color.peg.success
    let warning = Color.peg.warning 
    let error = Color.peg.error
}