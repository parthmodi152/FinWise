//
//  MainTabsView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-10-09.
//

import SwiftUI
import SwiftData
import AuthenticationServices

struct MainTabsView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel
    @Environment(\.modelContext) private var modelContext
    @Query var accounts: [Account]
    @State private var selection: Int = 0
    @State private var presentingLoginScreen = false
    
    var body: some View {
        NavigationView {
            TabView {
                Tab("Dashboard", systemImage: "tray.and.arrow.down.fill") {
                    DashboardView()
                }
                
                
                Tab("Transactions", systemImage: "tray.and.arrow.up.fill") {
                    ProfileView()
                }
                
                
                Tab("Settings", systemImage: "person.crop.circle.fill") {
                    ProfileView()
                }
            }
            .onAppear {
                checkAndAddCashAccount()  /// Check and add cash account when the view appears
            }
            .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
                authViewModel.signOut()
                if let userInfo = event.userInfo, let info = userInfo["info"] {
                    print(info)
                }
            }
        }
    }
    
    
    /// Function to check if a cash account exists, if not add a default cash account
    private func checkAndAddCashAccount() {
        if !accounts.contains(where: { $0.type == .cash }) {
            // Use user's local currency
            let localCurrency = Locale.current.currency?.identifier ?? "USD"
            let cashAccount = Account(name: "Cash", balance: 0.0, type: .cash, currencyCode: localCurrency)
            modelContext.insert(cashAccount)
            
            // Save the model context to persist changes
            do {
                try modelContext.save()
            } catch {
                print("Failed to save cash account: \(error.localizedDescription)")
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
    
    
    MainTabsView()
        .modelContainer(container)
        .environment(AuthenticationViewModel())
        .environment(PlaidLinkViewModel(modelContext: container.mainContext))
}
