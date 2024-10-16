//
//  PlaidLinkViewModel.swift
//  FinWise
//
//  Created by Parth Modi on 2024-09-02.
//

import Foundation
import FirebaseFunctions
import LinkKit
import SwiftData

@MainActor
@Observable class PlaidLinkViewModel {
    var isPresentingLink: Bool = false
    var linkController: LinkController?
    private var modelContext: ModelContext
    
    init (modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Asynchronous function to generate the link token and create the link handler
    func setupLinkHandler() async -> Bool {
        let functions = Functions.functions()
        
        do {
            let result = try await functions.httpsCallable("generateLinkToken").call()
            if let linkToken = result.data as? String {
                print("Got Link Token: \(linkToken)")
                await createLinkController(linkToken: linkToken)
                return linkController != nil
            } else {
                print("Failed to get a valid link token.")
                return false
            }
        } catch {
            print("Error generating link token: \(error)")
            return false
        }
    }
    
    // Create a Plaid Link handler and open the Link flow
    private func createLinkController(linkToken: String) async {
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { success in
            Task {
                await self.exchangePublicToken(publicToken: success.publicToken)
                self.isPresentingLink = false
            }
        }
        
        linkConfiguration.onExit = { exit in
            if let error = exit.error {
                print("Plaid Link exited with error: \(error)")
            } else {
                print("Plaid Link exited: \(exit.metadata)")
            }
            self.isPresentingLink = false
        }
        
        linkConfiguration.onEvent = { event in
            print("Plaid Link event: \(event)")
        }
        
        let result = Plaid.create(linkConfiguration)
        switch result {
        case .failure(let error):
            print("Unable to create Plaid handler due to: \(error)")
        case .success(let handler):
            print("Creating Link controller")
            self.linkController = LinkController(handler: handler)
        }
    }
    
    
    // Function to exchange the public token for an access token using Firebase Functions
    private func exchangePublicToken(publicToken: String) async {
        let functions = Functions.functions()
        
        do {
            let result = try await functions.httpsCallable("exchangePublicToken").call(["publicToken": publicToken])
            guard let responseData = result.data as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: responseData, options: []),
                  let plaidResponse = try? JSONDecoder().decode(PlaidResponse.self, from: jsonData) else {
                print("Failed to parse response data")
                return
            }
            
            // Sync accounts and transactions
            for item in plaidResponse.results {
                syncAccounts(item.accounts, bankName: item.bank_name)
                syncTransactions(added: item.added, modified: item.modified, removed: item.removed)
            }
        } catch {
            print("Error exchanging public token: \(error)")
        }
    }
    
    // Function to sync accounts data with SwiftData models
    private func syncAccounts(_ accounts: [PlaidAccount], bankName: String) {
        for plaidAccount in accounts {
            if findAccountById(plaidAccount.account_id) == nil {
                let account = Account(
                    id: plaidAccount.account_id,
                    name: plaidAccount.name,
                    balance: plaidAccount.balances.current,
                    type: AccountType(rawValue: plaidAccount.type.capitalized),
                    currencyCode: plaidAccount.balances.iso_currency_code,
                    bankName: bankName,
                    mask: plaidAccount.mask
                )
                modelContext.insert(account)
                print("Account with id \(plaidAccount.account_id) added with balance current: \(plaidAccount.balances.current ?? 0.0), \(plaidAccount.balances.available ?? 0.0)")
            } else {
                print("Account with id \(plaidAccount.account_id) already exists, skipping.")
            }
        }
        
        do {
            try modelContext.save()
            print("Accounts synced successfully")
        } catch {
            print("Failed to sync accounts: \(error)")
        }
    }
    
    // Function to sync transactions data with SwiftData models
    private func syncTransactions(added: [PlaidTransaction], modified: [PlaidTransaction], removed: [PlaidTransaction]) {
        for transaction in added {
            if let account = findAccountById(transaction.account_id) {
                // Check if a transaction with the same ID already exists
                if findTransactionById(transaction.transaction_id) == nil {
                    let newTransaction = createTransaction(from: transaction, for: account)
                    modelContext.insert(newTransaction)
                    print("Transaction with id \(transaction.transaction_id) added.")
                } else {
                    print("Transaction with id \(transaction.transaction_id) already exists, skipping.")
                }
            } else {
                print("Account with id \(transaction.account_id) not found for adding transaction \(transaction.transaction_id), skipping.")
            }
        }
        
        for transaction in modified {
            if let existingTransaction = findTransactionById(transaction.transaction_id) {
                updateTransaction(existingTransaction, with: transaction)
                print("Transaction with id \(transaction.transaction_id) modified.")
            } else {
                print("Transaction with id \(transaction.transaction_id) not found for modification, skipping.")
            }
        }
        
        for transaction in removed {
            if let existingTransaction = findTransactionById(transaction.transaction_id) {
                modelContext.delete(existingTransaction)
                print("Transaction with id \(transaction.transaction_id) removed.")
            } else {
                print("Transaction with id \(transaction.transaction_id) not found for removal, skipping.")
            }
        }
        
        do {
            try modelContext.save()
            print("Transactions synced successfully")
        } catch {
            print("Failed to sync transactions: \(error)")
        }
    }
    
    // Helper function to find Account by id
    private func findAccountById(_ id: String) -> Account? {
        var fetchDescriptor = FetchDescriptor<Account>(
            predicate: #Predicate { account in
                account.id == id
            }
        )
        
        fetchDescriptor.fetchLimit = 1
        
        return try? modelContext.fetch(fetchDescriptor).first
    }
    
    // Helper function to find Transaction by id
    private func findTransactionById(_ id: String) -> Transaction? {
        var fetchDescriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { transaction in
                transaction.id == id
            }
        )
        
        fetchDescriptor.fetchLimit = 1
        
        return try? modelContext.fetch(fetchDescriptor).first
    }
    
    // Helper function to create a new Transaction from PlaidTransaction
    private func createTransaction(from plaidTransaction: PlaidTransaction, for account: Account) -> Transaction {
        let category = findOrCreateCategory(detailed: plaidTransaction.personal_finance_category?.detailed ?? "", primary: plaidTransaction.personal_finance_category?.primary ?? "")
        
        return Transaction(
            id: plaidTransaction.transaction_id,
            name: plaidTransaction.name,
            category: category,
            date: DateFormatter.yyyyMMdd.date(from: plaidTransaction.date),
            amount: plaidTransaction.amount,
            currencyCode: plaidTransaction.iso_currency_code,
            account: account
        )
    }
    
    // Helper function to update an existing Transaction with new data
    private func updateTransaction(_ transaction: Transaction, with plaidTransaction: PlaidTransaction) {
        transaction.name = plaidTransaction.name
        transaction.amount = plaidTransaction.amount
        transaction.currencyCode = plaidTransaction.iso_currency_code
        transaction.date = DateFormatter.yyyyMMdd.date(from: plaidTransaction.date)
        
        if let category = findOrCreateCategory(detailed: plaidTransaction.personal_finance_category?.detailed ?? "", primary: plaidTransaction.personal_finance_category?.primary ?? "") {
            transaction.category = category
        }
    }
    
    /// Helper function to find or create a Category
    private func findOrCreateCategory(detailed: String, primary: String) -> Category? {
        // Attempt to get the category name and type from the mappings
        let name = categoryNameMapping[detailed]
        
        guard let type = categoryTypeMapping[primary], !type.isEmpty else {
            print("Error: Category type mapping not found for primary string: \(primary)")
            return nil
        }
        
        // Step 3: Fetch the correct category from the database or create a new one if it doesn't exist
        var fetchDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { category in
                category.name == name && category.type == type
            }
        )
        
        fetchDescriptor.fetchLimit = 1
        
        if let category = try? modelContext.fetch(fetchDescriptor).first {
            return category
        } else {
            // Clean the detailed string by removing the primary prefix and converting it to a human-readable name
            let categoryName = detailed
                .replacingOccurrences(of: "\(primary)_", with: "")
                .split(separator: "_")
                .map { $0.capitalized }
                .joined(separator: " ")
            
            // Create a new category under the known type
            let newCategory = Category(name: categoryName, type: CategoryType(rawValue: type))
            modelContext.insert(newCategory)
            print("Created new category: \(categoryName) under type \(type)")
            return newCategory
        }
    }
}

// Helper to format dates from the string date in Plaid's response
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
