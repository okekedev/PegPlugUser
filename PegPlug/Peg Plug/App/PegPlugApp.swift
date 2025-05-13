////
//  PegPlugApp.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/15/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct PegPlugApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel = AuthenticationViewModel()
    @StateObject var errorHandler = ErrorHandler()  // Add error handler
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                // Use HomeView directly instead of TabView
                HomeView()
                    .environmentObject(authViewModel)
                    .environmentObject(errorHandler)  // Inject error handler
                    .errorAlert(errorHandler: errorHandler)  // Add error alert
                    .onAppear {
                        // Set up error handler when view appears
                        authViewModel.setupErrorHandler(errorHandler)
                    }
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
                    .environmentObject(errorHandler)  // Inject error handler
                    .errorAlert(errorHandler: errorHandler)  // Add error alert
                    .onAppear {
                        // Set up error handler when view appears
                        authViewModel.setupErrorHandler(errorHandler)
                    }
            }
        }
    }
}
