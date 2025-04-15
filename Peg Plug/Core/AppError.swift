//
//  ErrorHandler.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import Combine

// MARK: - Error Types
enum AppError: Error {
    case network(String)
    case authentication(String)
    case database(String)
    case validation(String)
    case unknown(String)
    
    var message: String {
        switch self {
        case .network(let message):
            return message
        case .authentication(let message):
            return message
        case .database(let message):
            return message
        case .validation(let message):
            return message
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Error Handler
class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showingError = false
    
    func handle(_ error: Error) {
        DispatchQueue.main.async {
            if let appError = error as? AppError {
                self.currentError = appError
            } else {
                self.currentError = AppError.unknown(error.localizedDescription)
            }
            self.showingError = true
        }
    }
    
    func handleMessage(_ message: String, type: ErrorType = .unknown) {
        DispatchQueue.main.async {
            switch type {
            case .network:
                self.currentError = AppError.network(message)
            case .authentication:
                self.currentError = AppError.authentication(message)
            case .database:
                self.currentError = AppError.database(message)
            case .validation:
                self.currentError = AppError.validation(message)
            case .unknown:
                self.currentError = AppError.unknown(message)
            }
            self.showingError = true
        }
    }
    
    func reset() {
        currentError = nil
        showingError = false
    }
}

// MARK: - Error Types
enum ErrorType {
    case network
    case authentication
    case database
    case validation
    case unknown
}

// MARK: - View Extension for Error Alerts
extension View {
    func errorAlert(errorHandler: ErrorHandler) -> some View {
        self.alert(
            "Error",
            isPresented: Binding<Bool>(
                get: { errorHandler.showingError },
                set: { if !$0 { errorHandler.reset() } }
            ),
            actions: {
                Button("OK") {
                    errorHandler.reset()
                }
            },
            message: {
                Text(errorHandler.currentError?.message ?? "An unknown error occurred")
            }
        )
    }
    
    // Styled error alert that matches theme
    func styledErrorAlert(errorHandler: ErrorHandler) -> some View {
        self.modifier(ErrorAlertModifier(errorHandler: errorHandler))
    }
}

// MARK: - Styled Error Alert Modifier
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if errorHandler.showingError {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Allow dismissing by tapping outside
                        withAnimation {
                            errorHandler.reset()
                        }
                    }
                
                // Alert box
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color.peg.primaryRed)
                            .font(.system(size: 22))
                        
                        Text("Error")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.peg.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                errorHandler.reset()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.peg.textSecondary)
                        }
                    }
                    
                    Divider()
                    
                    // Message
                    Text(errorHandler.currentError?.message ?? "An unknown error occurred")
                        .font(.subheadline)
                        .foregroundColor(Color.peg.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Button
                    Button(action: {
                        withAnimation {
                            errorHandler.reset()
                        }
                    }) {
                        Text("OK")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.peg.primaryRed)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 4)
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    }
}
