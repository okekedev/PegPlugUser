//
//  ProfileView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


//
//  ProfileView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.peg.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // User info section
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.peg.primaryBlue)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(authViewModel.user?.displayName.prefix(1).uppercased() ?? "")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .padding(.top, 20)
                        
                        Text(authViewModel.user?.displayName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.peg.textPrimary)
                        
                        Text(authViewModel.user?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color.peg.textSecondary)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.peg.shadow.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding()
                    
                    // Settings list
                    VStack(spacing: 0) {
                        // Membership tier section
                        SectionHeader(title: "Membership")
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authViewModel.user?.membershipTier.capitalized ?? "Basic")
                                    .font(.headline)
                                    .foregroundColor(authViewModel.user?.membershipTier == "premium" ? 
                                                    Color.peg.accentGold : Color.peg.textPrimary)
                                
                                Text(authViewModel.user?.membershipTier == "premium" ? 
                                     "Premium benefits activated" : "Upgrade to unlock premium benefits")
                                    .font(.caption)
                                    .foregroundColor(Color.peg.textSecondary)
                            }
                            
                            Spacer()
                            
                            if authViewModel.user?.membershipTier != "premium" {
                                Button(action: {
                                    // Handle upgrade
                                    authViewModel.updateMembershipTier(tier: "premium")
                                }) {
                                    Text("Upgrade")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.peg.accentGold)
                                        .cornerRadius(20)
                                }
                            } else {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(Color.peg.accentGold)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        
                        Divider()
                            .padding(.leading)
                        
                        // Location permissions
                        NavigationLink(destination: LocationPermissionsView()) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(Color.peg.primaryRed)
                                    .frame(width: 24)
                                
                                Text("Location Permissions")
                                    .foregroundColor(Color.peg.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.peg.textSecondary.opacity(0.4))
                                    .font(.system(size: 14))
                            }
                            .padding()
                            .background(Color.white)
                        }
                        
                        Divider()
                            .padding(.leading)
                        
                        // Account section
                        SectionHeader(title: "Account")
                        
                        Button(action: {
                            showingLogoutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .foregroundColor(Color.peg.error)
                                    .frame(width: 24)
                                
                                Text("Log Out")
                                    .foregroundColor(Color.peg.error)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                        }
                    }
                    .background(Color.peg.background)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // App info
                    VStack(spacing: 4) {
                        Text("PegPlug")
                            .font(.headline)
                            .foregroundColor(Color.peg.primaryRed)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(Color.peg.textSecondary)
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingLogoutConfirmation) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        authViewModel.signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.peg.primaryBlue)
                .padding(.horizontal)
                .padding(.vertical, 10)
            
            Spacer()
        }
        .background(Color.peg.fieldBackground)
    }
}

struct LocationPermissionsView: View {
    @StateObject var locationManager = LocationManager.shared
    
    var body: some View {
        ZStack {
            Color.peg.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing:
                  20) {
                Text("Location Permissions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.peg.primaryBlue)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("PegPlug needs location access to:")
                        .font(.headline)
                        .foregroundColor(Color.peg.textPrimary)
                    
                    LocationPermissionRow(
                        icon: "mappin.circle.fill",
                        text: "Find deals near you"
                    )
                    
                    LocationPermissionRow(
                        icon: "bell.badge.fill",
                        text: "Notify you when you're near a deal"
                    )
                    
                    LocationPermissionRow(
                        icon: "timer",
                        text: "Activate redemption timers at locations"
                    )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                Text("Your location is only used while the app is running to find nearby deals and activate redemptions when you're at a participating location.")
                    .font(.subheadline)
                    .foregroundColor(Color.peg.textSecondary)
                    .padding(.top, 8)
                
                Spacer()
                
                Button(action: {
                    locationManager.requestLocationPermission()
                }) {
                    HStack {
                        Spacer()
                        Text(locationPermissionButtonText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                        Spacer()
                    }
                    .background(Color.peg.primaryRed)
                    .cornerRadius(12)
                }
                
                if locationPermissionDenied {
                    Text("To change location settings, go to your device's Settings > Privacy > Location Services")
                        .font(.caption)
                        .foregroundColor(Color.peg.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("Location Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var locationPermissionButtonText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Enable Location Services"
        case .authorizedWhenInUse:
            return "Enable Background Location"
        case .authorizedAlways:
            return "Location Services Enabled"
        case .restricted, .denied:
            return "Open Settings"
        @unknown default:
            return "Enable Location Services"
        }
    }
    
    var locationPermissionDenied: Bool {
        return locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted
    }
}

struct LocationPermissionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color.peg.primaryRed)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color.peg.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}