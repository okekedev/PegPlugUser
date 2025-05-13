//
//  DealsListView.swift
//  Peg Plug
//
//  Created by Christian Okeke on 4/25/25.
//


import SwiftUI

struct DealsListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedDealId: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.deals) { deal in
                        DealCard(
                            deal: deal,
                            merchant: viewModel.merchants[deal.merchantId],
                            hasActiveRedemption: viewModel.hasActiveRedemption(for: deal.id),
                            redemption: viewModel.activeRedemptions[deal.id]
                        )
                        .onTapGesture {
                            selectedDealId = deal.id
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Active Deals")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.peg.textSecondary)
            })
            .background(Color.peg.background)
        }
    }
}

// MARK: - Preview
struct DealsListView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock view model for preview
        let viewModel = HomeViewModel()
        // Add some sample deals for preview
        
        return DealsListView(
            viewModel: viewModel,
            selectedDealId: .constant(nil)
        )
    }
}