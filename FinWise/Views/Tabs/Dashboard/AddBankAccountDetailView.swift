//
//  AddBankAccountDetailView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-10-09.
//

import SwiftUI
import DotLottie
import SwiftData

struct AddBankAccountDetailView: View {
    @Environment(EntitlementManager.self) private var entitlementManager
    @Environment(PlaidLinkViewModel.self) private var plaidLinkViewModel
    @State private var showingSubscriptionView = false
    @State private var isPresentingLink = false
    @State private var linkSetupError: String? = nil
    @State private var buttonsDisabled = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DotLottieAnimation(
                    fileName: "piggie_money_animation", config: AnimationConfig(autoplay: true, loop: true))
                .view().aspectRatio(contentMode: .fit).frame(width: 280, height: 280)
                
                Text("Let's connect your accounts")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("Link your accounts so that we can analyze your spending.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 15) {
                    Button(action: handleButtonAction) {
                        HStack {
                            Image(systemName: "building.columns.fill")
                                .foregroundColor(Color("Color5")) // Pink for checking account
                            Text("Checking account")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color("Color6")) // White background for minimal look
                        .cornerRadius(12)
                    }
                    
                    Button(action: handleButtonAction) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(Color("Color2")) // Light green for credit card
                            Text("Credit card")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color("Color6")) // White background for minimal look
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                
                if let error = linkSetupError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 10)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Text("Powered by")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.color1)
                    Image("PlaidLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                }
                .padding()
                
            }
            .padding()
            .onAppear {
                setupPlaidLinkIfPro()
            }
            .sheet(isPresented: $showingSubscriptionView) {
                SubscriptionView()
            }
            .fullScreenCover(
                isPresented: Bindable(plaidLinkViewModel).isPresentingLink,
                content: {
                    if let controller = plaidLinkViewModel.linkController {
                        controller
                            .ignoresSafeArea(.all)
                    } else {
                        Text("Error: LinkController not initialized")
                    }
                }
            )
        }
    }
    
    // Handle button action based on user's subscription
    private func handleButtonAction() {
        if !entitlementManager.hasPro {
            showingSubscriptionView = true
        } else if buttonsDisabled {
            linkSetupError = "Unable to set up the bank connection. Please try again later."
        } else {
            isPresentingLink = true
        }
    }
    
    private func setupPlaidLinkIfPro() {
        Task {
            if entitlementManager.hasPro {
                buttonsDisabled = true
                let success = await plaidLinkViewModel.setupLinkHandler()
                
                if success, plaidLinkViewModel.linkController != nil {
                    buttonsDisabled = false
                    linkSetupError = nil
                } else {
                    buttonsDisabled = true
                    linkSetupError = "Failed to initialize the bank connection. Please check your network or try again."
                }
            } else {
                buttonsDisabled = true
            }
        }
    }
}

#Preview {
    let schema = Schema([
        Transaction.self,
        Account.self,
        Category.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: config)
    
    let entitlementManager = EntitlementManager()
    AddBankAccountDetailView()
        .environment(entitlementManager)
        .environment(PlaidLinkViewModel(modelContext: container.mainContext))
}
