import SwiftUI

struct RedemptionHistoryView: View {
    @StateObject private var viewModel = RedemptionHistoryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.peg.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("Redemption History")
                        .font(.custom("Georgia", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color.peg.primaryRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    // Filter tabs
                    HStack(spacing: 0) {
                        ForEach(RedemptionFilter.allCases, id: \.self) { option in
                            Button(action: {
                                viewModel.selectedFilter = option
                            }) {
                                Text(option.rawValue)
                                    .font(.subheadline)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(viewModel.selectedFilter == option ?
                                                    Color.peg.primaryRed : Color.peg.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                VStack {
                                    Spacer()
                                    if viewModel.selectedFilter == option {
                                        Rectangle()
                                            .fill(Color.peg.primaryRed)
                                            .frame(height: 3)
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 3)
                                    }
                                }
                            )
                        }
                    }
                    .background(Color.white)
                    .shadow(color: Color.peg.shadow.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                        Spacer()
                    } else if viewModel.filteredRedemptions.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "ticket")
                                .font(.system(size: 60))
                                .foregroundColor(Color.peg.primaryBlue.opacity(0.6))
                            
                            Text("No \(viewModel.selectedFilter.rawValue.lowercased()) redemptions")
                                .font(.headline)
                                .foregroundColor(Color.peg.textPrimary)
                            
                            if viewModel.selectedFilter == .active {
                                Text("Visit merchants to find and redeem deals!")
                                    .font(.subheadline)
                                    .foregroundColor(Color.peg.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        Spacer()
                    } else {
                        // Redemptions list
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredRedemptions) { redemptionDetail in
                                    RedemptionHistoryCard(
                                        redemption: redemptionDetail.redemption,
                                        deal: redemptionDetail.deal,
                                        merchant: redemptionDetail.merchant,
                                        location: redemptionDetail.location
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchRedemptions()
            }
        }
    }
}

// Remove redundant extension since RedemptionFilter already conforms to CaseIterable in RedemptionFilter.swift
// and remove redundant title property
// extension RedemptionFilter: CaseIterable {
//     static var allCases: [RedemptionFilter] {
//         return [.active, .completed, .expired]
//     }
//
//     var title: String {
//         return self.rawValue
//     }
// }

struct RedemptionHistoryCard: View {
    let redemption: Redemption
    let deal: Deal?
    let merchant: Merchant?
    let location: Location?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status banner
            HStack {
                Text(redemption.status.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(formatDate(redemption.timestamp))
                    .font(.caption)
                    .foregroundColor(Color.peg.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            Divider()
                .padding(.horizontal)
            
            // Deal info
            HStack(alignment: .center, spacing: 16) {
                // Merchant icon
                ZStack {
                    Circle()
                        .fill(Color.peg.primaryBlue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(merchant?.name.prefix(1).uppercased() ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.peg.primaryBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(deal?.title ?? "Unknown Deal")
                        .font(.headline)
                        .foregroundColor(Color.peg.textPrimary)
                    
                    Text(merchant?.name ?? "Unknown Merchant")
                        .font(.subheadline)
                        .foregroundColor(Color.peg.textSecondary)
                    
                    if let location = location {
                        Text(location.name)
                            .font(.caption)
                            .foregroundColor(Color.peg.textSecondary)
                    }
                }
                
                Spacer()
                
                // If active redemption, show countdown
                if redemption.status == Constants.RedemptionStatus.pending {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Expires in:")
                            .font(.caption)
                            .foregroundColor(Color.peg.textSecondary)
                        
                        Text(formatTimeRemaining(redemption.validityPeriod))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.peg.primaryRed)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.peg.shadow.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var statusColor: Color {
        switch redemption.status {
        case Constants.RedemptionStatus.pending:
            return Color.peg.primaryRed
        case Constants.RedemptionStatus.completed:
            return Color.peg.success
        case Constants.RedemptionStatus.expired:
            return Color.peg.error
        default:
            return Color.gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTimeRemaining(_ expiryDate: Date) -> String {
        let remainingTime = expiryDate.timeIntervalSince(Date())
        
        if remainingTime <= 0 {
            return "Expired"
        }
        
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        
        if minutes > 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        } else {
            return "\(minutes)m \(seconds)s"
        }
    }
}
