//
//  AuthenticationView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct AuthenticationView: View {
    // State
    @State private var isShowingLogin = true
    @State private var animateElements = false
    
    // Animation states
    @State private var logoScale: CGFloat = 0.8
    @State private var showFields = false
    @State private var animateButtons = false
    @State private var elementsOpacity: Double = 0
    
    // Environment
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var errorHandler: ErrorHandler
    
    var body: some View {
        ZStack {
            // Animated background with gradient
            PegAnimationBackground(isAnimating: $animateElements)
                .opacity(elementsOpacity)
            
            // Gold coins animation
            PegCoinAnimation()
                .opacity(elementsOpacity * 0.8)
            
            // Main content
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo area with animation
                        VStack {
                            // New location-based logo
                            PegLocationLogo()
                                .scaleEffect(logoScale)
                                .padding(.top, 20)
                                .padding(.bottom, 5)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Content with animation
                        VStack(spacing: 20) {
                            // Welcome text with animation
                            VStack(spacing: 5) {
                                Text(isShowingLogin ? "Welcome Back" : "Create Account")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text(isShowingLogin ?
                                    "Sign in to claim deals now" :
                                    "Join the community today")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .pegFadeIn(delay: 0.6)
                            
                            // Form container - using a more compact layout
                            VStack {
                                // Form content with animation
                                VStack {
                                    if isShowingLogin {
                                        LoginForm(showFields: showFields, animateButtons: animateButtons)
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .leading).combined(with: .opacity),
                                                removal: .move(edge: .trailing).combined(with: .opacity)
                                            ))
                                    } else {
                                        SignUpForm(showFields: showFields, animateButtons: animateButtons)
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)
                                            ))
                                    }
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 5)
                                .background(Color.white)
                                .cornerRadius(24)
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                            }
                            .opacity(showFields ? 1 : 0)
                            .offset(y: showFields ? 0 : 50)
                            .padding(.horizontal, 20)
                            
                            // Toggle between login and signup
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    isShowingLogin.toggle()
                                }
                            }) {
                                Text(isShowingLogin ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                                    .underline()
                            }
                            .opacity(showFields ? 1 : 0)
                            .pegFadeIn(delay: 1.4)
                            .padding(.top, 10)
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Start animations in sequence
        withAnimation(.easeIn(duration: 0.8)) {
            elementsOpacity = 1
        }
        
        withAnimation(Animation.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            logoScale = 1.0
        }
        
        // Begin background animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                animateElements = true
            }
        }
        
        // Trigger field animations after logo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showFields = true
            }
        }
        
        // Trigger button animations last
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateButtons = true
            }
        }
    }
}

// MARK: - Login Form Component
struct LoginForm: View {
    // Props
    let showFields: Bool
    let animateButtons: Bool
    
    // State
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    // Environment
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var errorHandler: ErrorHandler
    
    var body: some View {
        VStack(spacing: 25) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(Color.peg.textPrimary)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color.peg.primaryBlue)
                        .font(.system(size: 16))
                        .padding(.leading, 12)
                    
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.vertical, 12)
                }
                .background(Color.peg.fieldBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .offset(y: showFields ? 0 : 20)
            .opacity(showFields ? 1 : 0)
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                    .foregroundColor(Color.peg.textPrimary)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.peg.primaryBlue)
                        .font(.system(size: 16))
                        .padding(.leading, 12)
                    
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .padding(.vertical, 12)
                    } else {
                        SecureField("Enter your password", text: $password)
                            .padding(.vertical, 12)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color.peg.textSecondary)
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 12)
                }
                .background(Color.peg.fieldBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .offset(y: showFields ? 0 : 20)
            .opacity(showFields ? 1 : 0)
            
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color.peg.error)
                    .padding(.top, 4)
                    .padding(.horizontal, 20)
                    .offset(y: showFields ? 0 : 20)
                    .opacity(showFields ? 1 : 0)
            }
            
            // Forgot password
            HStack {
                Spacer()
                
                Button(action: {
                    // Forgot password action
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 14))
                        .foregroundColor(Color.peg.primaryBlue)
                        .underline()
                }
                .padding(.trailing, 20)
            }
            .opacity(animateButtons ? 1 : 0)
            
            // Login button
            Button(action: {
                authViewModel.signIn(email: email, password: password)
            }) {
                HStack {
                    Spacer()
                    
                    if authViewModel.isLoading {
                        PegLoadingAnimation(color: .white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.trailing, 8)
                        
                        Text("LOG IN")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
            }
            .buttonStyle(PegButtonStyle())
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
            .opacity(animateButtons ? (email.isEmpty || password.isEmpty ? 0.7 : 1.0) : 0)
            
            // Social login
            VStack(spacing: 15) {
                Text("OR CONTINUE WITH")
                    .font(.caption)
                    .foregroundColor(Color.peg.textSecondary)
                
                Button(action: {
                    signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill") // Use system icon as placeholder
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        
                        Text("Sign in with Google")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.peg.textPrimary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.peg.border, lineWidth: 1)
                    )
                    .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .opacity(animateButtons ? 1 : 0)
        }
        .padding(.vertical, 20)
    }
    
    // Function to handle Google Sign-In
    private func signInWithGoogle() {
        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // Use the method from AuthViewModel
            authViewModel.signInWithGoogle(fromViewController: rootViewController)
        } else {
            errorHandler.handle(AppError.unknown("Could not find root view controller"))
        }
    }
}

// MARK: - Sign Up Form Component
struct SignUpForm: View {
    // Props
    let showFields: Bool
    let animateButtons: Bool
    
    // State
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
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
                    .foregroundColor(Color.peg.textPrimary)
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(Color.peg.primaryBlue)
                        .font(.system(size: 16))
                        .padding(.leading, 12)
                    
                    TextField("Enter your full name", text: $displayName)
                        .padding(.vertical, 12)
                }
                .background(Color.peg.fieldBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .offset(y: showFields ? 0 : 20)
            .opacity(showFields ? 1 : 0)
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(Color.peg.textPrimary)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color.peg.primaryBlue)
                        .font(.system(size: 16))
                        .padding(.leading, 12)
                    
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.vertical, 12)
                }
                .background(Color.peg.fieldBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .offset(y: showFields ? 0 : 20)
            .opacity(showFields ? 1 : 0)
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                    .foregroundColor(Color.peg.textPrimary)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.peg.primaryBlue)
                        .font(.system(size: 16))
                        .padding(.leading, 12)
                    
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .padding(.vertical, 12)
                    } else {
                        SecureField("Enter your password", text: $password)
                            .padding(.vertical, 12)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color.peg.textSecondary)
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 12)
                }
                .background(Color.peg.fieldBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
                
                if !password.isEmpty && password.count < 6 {
                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(Color.peg.error)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .offset(y: showFields ? 0 : 20)
            .opacity(showFields ? 1 : 0)
            
            // Confirm Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.headline)
                    .foregroundColor(Color.peg.textPrimary)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.peg.primaryBlue)
                        .font(.system(size: 16))
                        .padding(.leading, 12)
                    
                    if showConfirmPassword {
                        TextField("Confirm your password", text: $confirmPassword)
                            .padding(.vertical, 12)
                    } else {
                        SecureField("Confirm your password", text: $confirmPassword)
                            .padding(.vertical, 12)
                    }
                    
                    Button(action: {
                        showConfirmPassword.toggle()
                    }) {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color.peg.textSecondary)
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 12)
                }
                .background(Color.peg.fieldBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
                
                if !confirmPassword.isEmpty && !passwordMatch {
                    Text("Passwords do not match")
                        .font(.caption)
                        .foregroundColor(Color.peg.error)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .offset(y: showFields ? 0 : 20)
            .opacity(showFields ? 1 : 0)
            
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color.peg.error)
                    .padding(.top, 4)
                    .padding(.horizontal, 20)
                    .offset(y: showFields ? 0 : 20)
                    .opacity(showFields ? 1 : 0)
            }
            
            // Sign up button
            Button(action: {
                authViewModel.signUp(email: email, password: password, displayName: displayName)
            }) {
                HStack {
                    Spacer()
                    
                    if authViewModel.isLoading {
                        PegLoadingAnimation(color: .white)
                    } else {
                        Text("CREATE ACCOUNT")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 16)
            }
            .buttonStyle(PegButtonStyle())
            .disabled(!isFormValid || authViewModel.isLoading)
            .opacity(animateButtons ? (isFormValid ? 1.0 : 0.6) : 0)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Terms of service text
            Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(Color.peg.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .opacity(animateButtons ? 0.7 : 0)
            
            // Social signup
            VStack(spacing: 15) {
                Text("OR SIGN UP WITH")
                    .font(.caption)
                    .foregroundColor(Color.peg.textSecondary)
                
                Button(action: {
                    signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill") // Use system icon as placeholder
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        
                        Text("Sign up with Google")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.peg.textPrimary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.peg.border, lineWidth: 1)
                    )
                    .shadow(color: Color.peg.shadow.opacity(0.1), radius: 3, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 5)
            .opacity(animateButtons ? 1 : 0)
        }
        .padding(.vertical, 20)
    }
    
    // Function to handle Google Sign-In
    private func signInWithGoogle() {
        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // Use the method from AuthViewModel
            authViewModel.signInWithGoogle(fromViewController: rootViewController)
        } else {
            errorHandler.handle(AppError.unknown("Could not find root view controller"))
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(ErrorHandler())
    }
}
