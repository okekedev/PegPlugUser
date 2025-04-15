//
//  OnboardingCard.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI

struct OnboardingCard: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header with dismiss button
            HStack {
                Text("How PegPlug Works")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.peg.textPrimary)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.peg.textSecondary)
                }
            }
            
            Divider()
            
            // Step 1
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.peg.primaryBlue.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Text("1")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.peg.primaryBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Find Pegs")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.peg.textPrimary)
                    
                    Text("Visit locations marked as Pegs on the map to spin for exclusive deals.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.peg.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Step 2
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.peg.primaryRed.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Text("2")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.peg.primaryRed)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Get Plugs")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.peg.textPrimary)
                    
                    Text("Spin the wheel at Pegs to win Plugs (deals) that you can redeem at the merchant.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.peg.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Step 3
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.peg.success.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Text("3")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.peg.success)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Redeem Your Deals")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.peg.textPrimary)
                    
                    Text("Show your active Plugs to store staff to validate and claim your rewards before they expire!")
                        .font(.system(size: 14))
                        .foregroundColor(Color.peg.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Tips
            VStack(alignment: .leading, spacing: 8) {
                Text("Premium members get more daily spins and better chances to win!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.peg.accentGold)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.peg.accentGold.opacity(0.1))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 5)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview
struct OnboardingCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.peg.background
                .ignoresSafeArea()
            
            OnboardingCard(onDismiss: {})
                .padding()
        }
    }
}