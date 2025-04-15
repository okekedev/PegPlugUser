////
//  SignUpFormView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/23/25.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct SignUpFormView: View {
    // Props
    let showFields: Bool
    let animateButtons: Bool
    
    // State
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    
    // Environment
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var errorHandler: ErrorHandler
    
    // Computed properties
    private var passwordMatch: Bool {
        return password == confirmPassword
    }
    
    private var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && !displayName.isEmpty && passwordMatch && password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.8))
                
                TextField("Enter your name", text: $displayName)
                    .textFieldStyle(GlassTextFieldStyle())
            }
            .padding(.horizontal, 30)
            
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
                
                if !password.isEmpty && password.count < 6 {
                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(Color.peg.error) // Updated from theme.error
                }
            }
            .padding(.horizontal, 30)
            
            // Confirm Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.8))
                
                SecureField("Confirm your password", text: $confirmPassword)
                    .textFieldStyle(GlassTextFieldStyle())
                
                if !confirmPassword.isEmpty && !passwordMatch {
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundColor(Color.peg.error) // Updated from theme.error
                }
            }
            .padding(.horizontal, 30)
            
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color.peg.error) // Updated from theme.error
                    .padding(.top, 4)
                    .padding(.horizontal, 30)
            }
            
            // Button section
            VStack(spacing: 20) {
                // Sign up button
                Button(action: {
                    authViewModel.signUp(email: email, password: password, displayName: displayName)
                }) {
                    HStack {
                        Spacer()
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("CREATE ACCOUNT")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.peg.primaryRed, Color.peg.primaryDarkBlue]), // Updated
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
                    .shadow(color: Color.peg.primaryRed.opacity(0.6), radius: 8) // Updated
                    .opacity(isFormValid ? 1.0 : 0.6)
                }
                .disabled(!isFormValid || authViewModel.isLoading)
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .opacity(animateButtons ? 1 : 0)
                .offset(y: animateButtons ? 0 : 20)
                
                // Separator
                OrSeparator()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
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
                        
                        Text("SIGN UP WITH GOOGLE")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            // Using gold colors
                            gradient: Gradient(colors: [Color(hex: "F1C232"), Color(hex: "DFB140")]), // Gold colors
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
                
                // Terms of service text
                Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    .opacity(animateButtons ? 0.7 : 0)
            }
            
            Spacer(minLength: 40)
        }
        .padding(.bottom, 50)
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

// IMPORTANT: Make sure to add GlassTextFieldStyle in a separate file if it's not already defined
/*
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
*/
