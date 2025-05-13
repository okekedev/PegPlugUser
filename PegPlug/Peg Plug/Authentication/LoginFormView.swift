////  LoginFormView.swift//  LoginFormView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/23/25.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct LoginFormView: View {
    // Props
    let showFields: Bool
    let animateButtons: Bool
    
    // State
    @State private var email = ""
    @State private var password = ""
    
    // Environment
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var errorHandler: ErrorHandler
    
    // Computed properties
    private var isLoginFormValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.8))
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(GlassTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            .padding(.horizontal, 30)
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.8))
                
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(GlassTextFieldStyle())
            }
            .padding(.horizontal, 30)
            
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color.peg.error)  // Updated from theme.error
                    .padding(.top, 4)
                    .padding(.horizontal, 30)
            }
            
            // Login buttons with slide animation
            VStack(spacing: 20) {
                // Login button
                Button(action: {
                    withAnimation {
                        authViewModel.signIn(email: email, password: password)
                    }
                }) {
                    HStack {
                        Spacer()
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("LOG IN")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.peg.primaryRed, Color.peg.primaryDarkBlue]),  // Updated
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
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
                    .shadow(color: Color.peg.primaryRed.opacity(0.6), radius: 8)  // Updated
                }
                .disabled(!isLoginFormValid || authViewModel.isLoading)
                .opacity(isLoginFormValid ? 1.0 : 0.6)
                .scaleEffect(authViewModel.isLoading ? 0.95 : 1.0)
                .padding(.horizontal, 30)
                .opacity(animateButtons ? 1 : 0)
                .offset(y: animateButtons ? 0 : 20)
                
                // Separator
                OrSeparator()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 5)
                    .opacity(animateButtons ? 0.7 : 0)
                
                // Google Sign In Button with updated theme
                Button(action: {
                    signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                        
                        Text("CONTINUE WITH GOOGLE")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            // Using gold color for Google button - you should add this to PegTheme.swift
                            gradient: Gradient(colors: [Color(hex: "F1C232"), Color(hex: "DFB140")]),  // Gold colors
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
                }
                .padding(.horizontal, 30)
                .opacity(animateButtons ? 1 : 0)
                .offset(y: animateButtons ? 0 : 20)
                
                // Forgot password
                Button(action: {
                    // Handle forgot password
                }) {
                    Text("FORGOT PASSWORD?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "F1C232"))  // Gold color
                        .padding(.vertical, 10)
                }
                .opacity(animateButtons ? 0.9 : 0)
                .padding(.top, 5)
            }
            .padding(.top, 10)
        }
    }
    
    // Function to handle Google Sign-In
    private func signInWithGoogle() {
        // Get the root view controller using the current approach
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // Use the method from AuthViewModel
            authViewModel.signInWithGoogle(fromViewController: rootViewController)
        } else {
            errorHandler.handle(AppError.unknown("Could not find root view controller"))
        }
    }
}

// MARK: - Reusable components
struct OrSeparator: View {
    var body: some View {
        HStack {
            VStack { Divider() }
                .background(Color.white.opacity(0.3))
            
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 40, height: 40)
                    .opacity(0.5)
                
                Text("OR")
                    .foregroundColor(Color.white.opacity(0.8))
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            VStack { Divider() }
                .background(Color.white.opacity(0.3))
        }
    }
}

// NOTE: GlassTextFieldStyle is removed from here to avoid redeclaration
// Use your existing GlassTextFieldStyle component
