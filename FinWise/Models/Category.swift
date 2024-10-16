//
//  Category.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import Foundation
import SwiftData

enum CategoryType: String, Codable, CaseIterable {
    case INCOME = "Income"
    case TRANSFER_IN = "Transfer In"
    case TRANSFER_OUT = "Transfer Out"
    case LOAN_PAYMENTS = "Loan Payments"
    case BANK_FEES = "Bank Fees"
    case ENTERTAINMENT = "Entertainment"
    case FOOD_AND_DRINK = "Food And Drink"
    case GENERAL_MERCHANDISE = "General Merchandise"
    case HOME_IMPROVEMENT = "Home Improvement"
    case MEDICAL = "Medical"
    case PERSONAL_CARE = "Personal Care"
    case GENERAL_SERVICES = "General Services"
    case GOVERNMENT_AND_NON_PROFIT = "Government And Non Profit"
    case TRANSPORTATION = "Transportation"
    case TRAVEL = "Travel"
    case RENT_AND_UTILITIES = "Rent And Utilities"
}

@Model
final class Category {
    var name: String?
    var emoji: String?
    var type: String?  // Storing the raw value of CategoryType as a string
    var budget: Double?  // Budget attribute to store budgeted amount
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category) var transactions: [Transaction]?
    
    init(name: String? = "", emoji: String? = "", type: CategoryType? = nil, budget: Double? = 0.0, transactions: [Transaction]? = [Transaction]()) {
        self.name = name
        self.emoji = emoji
        self.type = type?.rawValue
        self.budget = budget
        self.transactions = transactions
    }
    
    // Static function to calculate total spending for each category type
    // Static function to calculate total spending for each category type
    static func totalSpending(for categoryType: CategoryType, in modelContext: ModelContext) -> Double {
        let fetchDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { category in
                category.type ?? "" == categoryType.rawValue
            }
        )
        
        do {
            let categories = try modelContext.fetch(fetchDescriptor)
            
            // Sum the amount of all transactions in the fetched categories
            let totalSpending = categories.flatMap { $0.transactions ?? [] }
                .reduce(0.0) { $0 + ($1.amount ?? 0.0) }
            
            return totalSpending
        } catch {
            print("Failed to fetch transactions for category: \(categoryType.rawValue), error: \(error)")
            return 0.0
        }
    }
    
    
    static func defaultCategories() -> [Category] {
        return [
            // Income
            Category(name: "Dividends", emoji: "💸", type: .INCOME),
            Category(name: "Interest Earned", emoji: "💰", type: .INCOME),
            Category(name: "Retirement Pension", emoji: "🏦", type: .INCOME),
            Category(name: "Tax Refund", emoji: "🧾", type: .INCOME),
            Category(name: "Unemployment", emoji: "💼", type: .INCOME),
            Category(name: "Wages", emoji: "💵", type: .INCOME),
            Category(name: "Other Income", emoji: "💲", type: .INCOME),
            
            // Transfer In
            Category(name: "Cash Advances and Loans", emoji: "💳", type: .TRANSFER_IN),
            Category(name: "Deposit", emoji: "🏦", type: .TRANSFER_IN),
            Category(name: "Investment and Retirement Funds", emoji: "📈", type: .TRANSFER_IN),
            Category(name: "Savings", emoji: "💾", type: .TRANSFER_IN),
            Category(name: "Account Transfer", emoji: "🔄", type: .TRANSFER_IN),
            Category(name: "Other Transfer In", emoji: "💼", type: .TRANSFER_IN),
            
            // Transfer Out
            Category(name: "Investment and Retirement Funds", emoji: "📉", type: .TRANSFER_OUT),
            Category(name: "Savings", emoji: "💸", type: .TRANSFER_OUT),
            Category(name: "Withdrawal", emoji: "🏧", type: .TRANSFER_OUT),
            Category(name: "Account Transfer", emoji: "🔄", type: .TRANSFER_OUT),
            Category(name: "Other Transfer Out", emoji: "💼", type: .TRANSFER_OUT),
            
            // Loan Payments
            Category(name: "Car Payment", emoji: "🚗", type: .LOAN_PAYMENTS),
            Category(name: "Credit Card Payment", emoji: "💳", type: .LOAN_PAYMENTS),
            Category(name: "Personal Loan Payment", emoji: "📄", type: .LOAN_PAYMENTS),
            Category(name: "Mortgage Payment", emoji: "🏡", type: .LOAN_PAYMENTS),
            Category(name: "Student Loan Payment", emoji: "🎓", type: .LOAN_PAYMENTS),
            Category(name: "Other Payment", emoji: "💸", type: .LOAN_PAYMENTS),
            
            
            // Bank Fees
            Category(name: "ATM Fees", emoji: "🏧", type: .BANK_FEES),
            Category(name: "Foreign Transaction Fees", emoji: "🌐", type: .BANK_FEES),
            Category(name: "Insufficient Funds", emoji: "🚫", type: .BANK_FEES),
            Category(name: "Interest Charge", emoji: "💳", type: .BANK_FEES),
            Category(name: "Overdraft Fees", emoji: "📉", type: .BANK_FEES),
            Category(name: "Other Bank Fees", emoji: "🏦", type: .BANK_FEES),
            
            // Entertainment
            Category(name: "Casinos and Gambling", emoji: "🎰", type: .ENTERTAINMENT),
            Category(name: "Music and Audio", emoji: "🎵", type: .ENTERTAINMENT),
            Category(name: "Sporting Events, Amusement Parks, and Museums", emoji: "🎟️", type: .ENTERTAINMENT),
            Category(name: "TV and Movies", emoji: "📺", type: .ENTERTAINMENT),
            Category(name: "Video Games", emoji: "🎮", type: .ENTERTAINMENT),
            Category(name: "Other Entertainment", emoji: "🎭", type: .ENTERTAINMENT),
            
            
            // Food and Drink
            Category(name: "Beer, Wine, and Liquor", emoji: "🍺", type: .FOOD_AND_DRINK),
            Category(name: "Coffee", emoji: "☕", type: .FOOD_AND_DRINK),
            Category(name: "Fast Food", emoji: "🍔", type: .FOOD_AND_DRINK),
            Category(name: "Groceries", emoji: "🛒", type: .FOOD_AND_DRINK),
            Category(name: "Restaurant", emoji: "🍽️", type: .FOOD_AND_DRINK),
            Category(name: "Vending Machines", emoji: "🤖", type: .FOOD_AND_DRINK),
            Category(name: "Other Food and Drink", emoji: "🍲", type: .FOOD_AND_DRINK),
            
            // General Merchandise
            Category(name: "Bookstores and Newsstands", emoji: "📚", type: .GENERAL_MERCHANDISE),
            Category(name: "Clothing and Accessories", emoji: "👗", type: .GENERAL_MERCHANDISE),
            Category(name: "Convenience Stores", emoji: "🏪", type: .GENERAL_MERCHANDISE),
            Category(name: "Department Stores", emoji: "🏬", type: .GENERAL_MERCHANDISE),
            Category(name: "Discount Stores", emoji: "💸", type: .GENERAL_MERCHANDISE),
            Category(name: "Electronics", emoji: "💻", type: .GENERAL_MERCHANDISE),
            Category(name: "Gifts and Novelties", emoji: "🎁", type: .GENERAL_MERCHANDISE),
            Category(name: "Office Supplies", emoji: "📎", type: .GENERAL_MERCHANDISE),
            Category(name: "Online Marketplaces", emoji: "🛒", type: .GENERAL_MERCHANDISE),
            Category(name: "Pet Supplies", emoji: "🐾", type: .GENERAL_MERCHANDISE),
            Category(name: "Sporting Goods", emoji: "⚽", type: .GENERAL_MERCHANDISE),
            Category(name: "Superstores", emoji: "🛍️", type: .GENERAL_MERCHANDISE),
            Category(name: "Tobacco and Vape", emoji: "🚬", type: .GENERAL_MERCHANDISE),
            Category(name: "Other General Merchandise", emoji: "🛒", type: .GENERAL_MERCHANDISE),
            
            // Home Improvement
            Category(name: "Furniture", emoji: "🛋️", type: .HOME_IMPROVEMENT),
            Category(name: "Hardware", emoji: "🔨", type: .HOME_IMPROVEMENT),
            Category(name: "Repair and Maintenance", emoji: "🛠️", type: .HOME_IMPROVEMENT),
            Category(name: "Security", emoji: "🔒", type: .HOME_IMPROVEMENT),
            Category(name: "Other Home Improvement", emoji: "🏡", type: .HOME_IMPROVEMENT),
            
            // Medical
            Category(name: "Dental Care", emoji: "🦷", type: .MEDICAL),
            Category(name: "Eye Care", emoji: "👓", type: .MEDICAL),
            Category(name: "Nursing Care", emoji: "🏥", type: .MEDICAL),
            Category(name: "Pharmacies and Supplements", emoji: "💊", type: .MEDICAL),
            Category(name: "Primary Care", emoji: "👩‍⚕️", type: .MEDICAL),
            Category(name: "Veterinary Services", emoji: "🐶", type: .MEDICAL),
            Category(name: "Other Medical", emoji: "🩺", type: .MEDICAL),
            
            // Personal Care
            Category(name: "Gyms and Fitness Centers", emoji: "🏋️‍♂️", type: .PERSONAL_CARE),
            Category(name: "Hair and Beauty", emoji: "💇‍♀️", type: .PERSONAL_CARE),
            Category(name: "Laundry and Dry Cleaning", emoji: "👔", type: .PERSONAL_CARE),
            Category(name: "Other Personal Care", emoji: "🧴", type: .PERSONAL_CARE),
            
            // General Services
            Category(name: "Accounting and Financial Planning", emoji: "💼", type: .GENERAL_SERVICES),
            Category(name: "Automotive", emoji: "🚗", type: .GENERAL_SERVICES),
            Category(name: "Childcare", emoji: "👶", type: .GENERAL_SERVICES),
            Category(name: "Consulting and Legal", emoji: "📜", type: .GENERAL_SERVICES),
            Category(name: "Education", emoji: "🎓", type: .GENERAL_SERVICES),
            Category(name: "Insurance", emoji: "📑", type: .GENERAL_SERVICES),
            Category(name: "Postage and Shipping", emoji: "✉️", type: .GENERAL_SERVICES),
            Category(name: "Storage", emoji: "📦", type: .GENERAL_SERVICES),
            Category(name: "Other General Services", emoji: "🛠️", type: .GENERAL_SERVICES),
            
            // Government and Non-Profit
            Category(name: "Donations", emoji: "💖", type: .GOVERNMENT_AND_NON_PROFIT),
            Category(name: "Government Departments and Agencies", emoji: "🏛️", type: .GOVERNMENT_AND_NON_PROFIT),
            Category(name: "Tax Payment", emoji: "💸", type: .GOVERNMENT_AND_NON_PROFIT),
            Category(name: "Other Government And Non Profit", emoji: "⚖️", type: .GOVERNMENT_AND_NON_PROFIT),
            
            // Transportation
            Category(name: "Bikes and Scooters", emoji: "🚲", type: .TRANSPORTATION),
            Category(name: "Gas", emoji: "⛽", type: .TRANSPORTATION),
            Category(name: "Parking", emoji: "🅿️", type: .TRANSPORTATION),
            Category(name: "Public Transit", emoji: "🚌", type: .TRANSPORTATION),
            Category(name: "Taxis and Ride Shares", emoji: "🚕", type: .TRANSPORTATION),
            Category(name: "Tolls", emoji: "🛣️", type: .TRANSPORTATION),
            Category(name: "Other Transportation", emoji: "🚗", type: .TRANSPORTATION),
            
            // Travel
            Category(name: "Flights", emoji: "✈️", type: .TRAVEL),
            Category(name: "Lodging", emoji: "🏨", type: .TRAVEL),
            Category(name: "Rental Cars", emoji: "🚗", type: .TRAVEL),
            Category(name: "Other Travel", emoji: "🧳", type: .TRAVEL),
            
            // Rent and Utilities
            Category(name: "Gas and Electricity", emoji: "⚡", type: .RENT_AND_UTILITIES),
            Category(name: "Internet and Cable", emoji: "🌐", type: .RENT_AND_UTILITIES),
            Category(name: "Rent", emoji: "🏠", type: .RENT_AND_UTILITIES),
            Category(name: "Sewage and Waste Management", emoji: "🚮", type: .RENT_AND_UTILITIES),
            Category(name: "Telephone", emoji: "📞", type: .RENT_AND_UTILITIES),
            Category(name: "Water", emoji: "💧", type: .RENT_AND_UTILITIES),
            Category(name: "Other Utilities", emoji: "🔧", type: .RENT_AND_UTILITIES)
        ]
    }
}
