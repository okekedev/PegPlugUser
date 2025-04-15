//
//  RedemptionView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


//
//  RedemptionView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//

import SwiftUI
import Combine
import MapKit

struct RedemptionView: View {
    let redemption: Redemption
    let deal: Deal
    let merchant: Merchant?
    let location: Location?
    
    @StateObject private var viewModel = RedemptionViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var timeRemaining: TimeInterval
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerConnector: Cancellable?
    @State private var showValidationDialog = false
    
    init(redemption: Redemption, deal: Deal, merchant: Merchant? = nil, location: Location? = nil) {
        self.redemption = redemption
        self.deal = deal
        self.merchant = merchant
        self.location = location
        self._timeRemaining = State(initialValue: redemption.remainingTime)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with merchant info
                if let merchant = merchant {
                    HStack(spacing: 14) {
                        if !merchant.logo.isEmpty {
                            AsyncImage(url: URL(string: merchant.logo)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.peg.primaryBlue)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(merchant.name.prefix(1).uppercased())
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        } else {
                            Circle()
                                .fill(Color.peg.primaryBlue)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(merchant.name.prefix(1).uppercased())
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(merchant.name)
                                .font(.headline)
                                .foregroundColor(Color.peg.textPrimary)
                            
                            Text(deal.title)
                                .font(.subheadline)
                                .foregroundColor(Color.peg.textSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // Location info with "Drive to Deal" button
                if let location = location {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(location.name)
                            .font(.headline)
                            .foregroundColor(Color.peg.textPrimary)
                        
                        Text(location.address)
                            .font(.subheadline)
                            .foregroundColor(Color.peg.textSecondary)
                        
                        Button(action: {
                            openMaps(location: location)
                        }) {
                            Label("Drive to Deal", systemImage: "car.fill")
                                .font(.headline)
                                .foregroundColor(Color.peg.primaryBlue)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.peg.primaryBlue, lineWidth: 2)
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // Countdown timer
                VStack(spacing: 8) {
                    Text("Time Remaining")
                        .font(.headline)
                        .foregroundColor(Color.peg.textPrimary)
                    
                    Text(timeString(from: max(0, timeRemaining)))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(timeRemaining > 300 ? Color.peg.primaryBlue : Color.peg.primaryRed)
                        // Add subtle pulsating animation when time is low
                        .scaleEffect(timeRemaining < 300 ? 1.0 + 0.05 * sin(Double(Date().timeIntervalSince1970) * 3) : 1.0)
                        .animation(.easeInOut(duration: 0.5), value: timeRemaining < 300)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(timeRemaining < 300 ? Color.peg.primaryRed : Color.peg.border, lineWidth: timeRemaining < 300 ? 2 : 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // QR code
                VStack(spacing: 12) {
                    Text("Show this code to the merchant")
                        .font(.headline)
                        .foregroundColor(Color.peg.textPrimary)
                    
                    QRCodeView(redemptionId: redemption.id, dealTitle: deal.title)
                        .frame(height: 220)
                    
                    Text("Redemption Code")
                        .font(.caption)
                        .foregroundColor(Color.peg.textSecondary)
                    
                    Text(redemption.id.prefix(8).uppercased())
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(Color.peg.primaryBlue)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 1)
                )
                .shadow(color: Color.peg.shadow.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Spacer(minLength: 20)
                
                // Action Buttons
                if timeRemaining > 0 {
                    // Validate Deal button (for merchant)
                    Button(action: {
                        showValidationDialog = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Validate Deal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                            Spacer()
                        }
                        .background(Color.peg.success)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 12)
                    
                    // Cancel button (for user)
                    Button(action: {
                        viewModel.cancelRedemption(redemptionId: redemption.id) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Cancel Redemption")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                            Spacer()
                        }
                        .background(Color.peg.error)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text("This redemption has expired")
                        .font(.headline)
                        .foregroundColor(Color.peg.error)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
        .background(Color.peg.background)
        .navigationTitle("Active Redemption")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timerConnector?.cancel()
        }
        .alert(isPresented: $showValidationDialog) {
            Alert(
                title: Text("Validate Deal"),
                message: Text("This action is for business staff only. Are you sure you want to validate this deal?"),
                primaryButton: .default(Text("Validate")) {
                    // Call the completeRedemption method which will update status and add completedAt timestamp
                    viewModel.completeRedemption(redemptionId: redemption.id) {
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
        timerConnector = timer.connect()
        
        // Update the time remaining every second
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else if redemption.status == Constants.RedemptionStatus.pending {
                // Automatically update status to expired when timer hits zero
                viewModel.expireRedemption(redemptionId: redemption.id)
            }
        }
    }
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private func openMaps(location: Location) {
        let coordinate = location.coordinate
        
        // Open Apple Maps with directions
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// QR Code View
struct QRCodeView: View {
    let redemptionId: String
    let dealTitle: String
    
    var body: some View {
        VStack {
            Image(systemName: "qrcode")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.peg.textPrimary)
                .frame(width: 180, height: 180)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.peg.border, lineWidth: 2)
                )
        }
    }
}

// Animation extension for RedemptionView transitions
extension AnyTransition {
    static var redemptionTransition: AnyTransition {
        let insertion = AnyTransition.opacity.combined(with: .scale(scale: 0.95))
        let removal = AnyTransition.opacity.combined(with: .scale(scale: 0.95))
        return .asymmetric(insertion: insertion, removal: removal)
    }
}