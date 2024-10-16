//
//  DashboardView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import SwiftUI
import SwiftData
import Charts
import Foundation

struct DashboardView: View {
    @Environment(PlaidLinkViewModel.self) private var plaidLinkViewModel
        @Environment(\.modelContext) var modelContext
        @Query var accounts: [Account]
        @Query var categories: [Category]
        @Query var transactions: [Transaction]
        
        // State variables to track the view mode and dropdown selection
        @State private var selectedFrequency: AccountBalanceChartView.Frequency = .monthly
        @State private var selectedAccountIndex: Int? = 0
    
    var body: some View {
        VStack {
            // Calculate the net worth based on all accounts
            DashboardHeader(netWorth: calculateNetWorth())
            
            // Dropdown Menu to switch between Monthly and Yearly charts
                        Picker("View Mode", selection: $selectedFrequency) {
                            Text("Monthly").tag(AccountBalanceChartView.Frequency.monthly)
                            Text("Yearly").tag(AccountBalanceChartView.Frequency.yearly)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
            
            // Full-screen height ScrollView for vertical sliding of charts

            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                        AccountBalanceChartView(accountId: account.id ?? "", frequency: selectedFrequency)
                    }
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .trailing)))
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedAccountIndex)
            .scrollIndicators(.never)
            
            // Display list of accounts
            List {
                // Display each account as a list item
                ForEach(accounts, id: \.id) { account in
                    NavigationLink(destination: AccountDetailView(account: account)) {
                        HStack {
                            Text(account.name ?? "Unnamed Account")
                                .font(.headline)
                            Spacer()
                            Text("\(account.balance ?? 0.0, specifier: "%.2f") \(account.currencyCode ?? "USD")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // "Add Bank Account" button
                NavigationLink(destination: AddBankAccountDetailView()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add Bank Account")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("Dashboard")
        .padding()
    }
    
    // Function to calculate the total net worth
    private func calculateNetWorth() -> Double {
        return accounts.reduce(0) { total, account in
            if account.type == .credit {
                // Subtract credit account balance from net worth
                return total - (account.balance ?? 0.0)
            } else {
                // Add other types of accounts
                return total + (account.balance ?? 0.0)
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
    // Create a sample cash account for the preview
    let sampleCashAccount = Account(name: "Cash", balance: 1000.0, type: .cash, currencyCode: Locale.current.currency?.identifier ?? "USD")
    let sampleCreditAccount = Account(name: "Credit Card", balance: 500.0, type: .credit, currencyCode: Locale.current.currency?.identifier ?? "USD")
    let sampleCreditAccount2 = Account(name: "Credit Card 2", balance: 500.0, type: .credit, currencyCode: Locale.current.currency?.identifier ?? "USD")
    
    let sampleTransaction1 = Transaction(id: "1", name: "Rent", category: nil, date: Date(), amount: 1020.60, currencyCode: "USD", account: sampleCashAccount)
    
    let sampleTransaction2 = Transaction(id: "2", name: "Groceries", category: nil, date: Date().addingTimeInterval(-60*60*24*30), amount: 600.00, currencyCode: "CAD", account: sampleCashAccount)
    
    // Insert the sample account into the preview context
    container.mainContext.insert(sampleCashAccount)
    container.mainContext.insert(sampleCreditAccount)
    container.mainContext.insert(sampleCreditAccount2)
    
    container.mainContext.insert(sampleTransaction1)
    container.mainContext.insert(sampleTransaction2)
    
    
    return DashboardView()
        .modelContainer(container)
        .environment(PlaidLinkViewModel(modelContext: container.mainContext))
}
