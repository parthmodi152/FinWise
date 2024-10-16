//
//  ContentView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AuthenticationViewModel.self) private var authViewModel
    
    var body: some View {
        if authViewModel.authenticationState != .unauthenticated {
            // Show the main content of the app if the user is authenticated
            MainTabsView()
        } else {
            // Show the AuthView if the user is not authenticated
            AuthView()
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
    
    
    return ContentView()
        .environment(AuthenticationViewModel())
        .environment(PlaidLinkViewModel(modelContext: container.mainContext))
        .environment(entitlementManager)
        .environment(SubscriptionsManager(entitlementManager: entitlementManager))
}
