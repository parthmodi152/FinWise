//
//  AccountDetailView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-10-09.
//

import SwiftUI

struct AccountDetailView: View {
    var account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(account.name ?? "Unnamed Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Balance: \(account.balance ?? 0.0, specifier: "%.2f") \(account.currencyCode ?? "USD")")
                .font(.title2)
            
            Text("Account Type: \(account.type?.rawValue ?? "Unknown")")
                .font(.title3)
                .padding(.top, 10)
            
            // Additional details can go here...
            
            Spacer()
        }
        .padding()
        .navigationTitle(account.name ?? "Account Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Create a sample cash account for the preview
    let sampleCashAccount = Account(name: "Cash", balance: 1000.0, type: .cash, currencyCode: Locale.current.currency?.identifier ?? "USD")
    
    AccountDetailView(account: sampleCashAccount)
}
