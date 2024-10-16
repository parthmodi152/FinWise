//
//  Plaid.swift
//  FinWise
//
//  Created by Parth Modi on 2024-09-03.
//

import Foundation

// Codable structs to map Plaid API response
struct PlaidAccount: Codable {
    let account_id: String
    let name: String
    let balances: Balances
    let type: String
    let subtype: String?
    let mask: String?
    
    struct Balances: Codable {
        let available: Double?
        let current: Double?
        let iso_currency_code: String?
    }
}

struct PlaidItem: Codable {
    let item_id: String
    let bank_name: String
    let accounts: [PlaidAccount]
    let added: [PlaidTransaction]
    let modified: [PlaidTransaction]
    let removed: [PlaidTransaction]
}

struct PlaidResponse: Codable {
    let status: String
    let results: [PlaidItem]
}

struct PlaidTransaction: Codable {
    let transaction_id: String
    let account_id: String
    let name: String
    let amount: Double
    let date: String
    let iso_currency_code: String?
    let personal_finance_category: PlaidCategory?
    
    struct PlaidCategory: Codable {
        let primary: String
        let detailed: String
    }
}


let categoryNameMapping: [String: String] = [
    "INCOME_DIVIDENDS": "Dividends",
    "INCOME_INTEREST_EARNED": "Interest Earned",
    "INCOME_RETIREMENT_PENSION": "Retirement Pension",
    "INCOME_TAX_REFUND": "Tax Refund",
    "INCOME_UNEMPLOYMENT": "Unemployment",
    "INCOME_WAGES": "Wages",
    "INCOME_OTHER_INCOME": "Other Income",
    
    "TRANSFER_IN_CASH_ADVANCES_AND_LOANS": "Cash Advances and Loans",
    "TRANSFER_IN_DEPOSIT": "Deposit",
    "TRANSFER_IN_INVESTMENT_AND_RETIREMENT_FUNDS": "Investment and Retirement Funds",
    "TRANSFER_IN_SAVINGS": "Savings",
    "TRANSFER_IN_ACCOUNT_TRANSFER": "Account Transfer",
    "TRANSFER_IN_OTHER_TRANSFER_IN": "Other Transfer In",
    
    "TRANSFER_OUT_INVESTMENT_AND_RETIREMENT_FUNDS": "Investment and Retirement Funds",
    "TRANSFER_OUT_SAVINGS": "Savings",
    "TRANSFER_OUT_WITHDRAWAL": "Withdrawal",
    "TRANSFER_OUT_ACCOUNT_TRANSFER": "Account Transfer",
    "TRANSFER_OUT_OTHER_TRANSFER_OUT": "Other Transfer Out",
    
    "LOAN_PAYMENTS_CAR_PAYMENT": "Car Payment",
    "LOAN_PAYMENTS_CREDIT_CARD_PAYMENT": "Credit Card Payment",
    "LOAN_PAYMENTS_PERSONAL_LOAN_PAYMENT": "Personal Loan Payment",
    "LOAN_PAYMENTS_MORTGAGE_PAYMENT": "Mortgage Payment",
    "LOAN_PAYMENTS_STUDENT_LOAN_PAYMENT": "Student Loan Payment",
    "LOAN_PAYMENTS_OTHER_PAYMENT": "Other Payment",
    
    "BANK_FEES_ATM_FEES": "ATM Fees",
    "BANK_FEES_FOREIGN_TRANSACTION_FEES": "Foreign Transaction Fees",
    "BANK_FEES_INSUFFICIENT_FUNDS": "Insufficient Funds",
    "BANK_FEES_INTEREST_CHARGE": "Interest Charge",
    "BANK_FEES_OVERDRAFT_FEES": "Overdraft Fees",
    "BANK_FEES_OTHER_BANK_FEES": "Other Bank Fees",
    
    "ENTERTAINMENT_CASINOS_AND_GAMBLING": "Casinos and Gambling",
    "ENTERTAINMENT_MUSIC_AND_AUDIO": "Music and Audio",
    "ENTERTAINMENT_SPORTING_EVENTS_AMUSEMENT_PARKS_AND_MUSEUMS": "Sporting Events, Amusement Parks, and Museums",
    "ENTERTAINMENT_TV_AND_MOVIES": "TV and Movies",
    "ENTERTAINMENT_VIDEO_GAMES": "Video Games",
    "ENTERTAINMENT_OTHER_ENTERTAINMENT": "Other Entertainment",
    
    "FOOD_AND_DRINK_BEER_WINE_AND_LIQUOR": "Beer, Wine, and Liquor",
    "FOOD_AND_DRINK_COFFEE": "Coffee",
    "FOOD_AND_DRINK_FAST_FOOD": "Fast Food",
    "FOOD_AND_DRINK_GROCERIES": "Groceries",
    "FOOD_AND_DRINK_RESTAURANT": "Restaurant",
    "FOOD_AND_DRINK_VENDING_MACHINES": "Vending Machines",
    "FOOD_AND_DRINK_OTHER_FOOD_AND_DRINK": "Other Food and Drink",
    
    "GENERAL_MERCHANDISE_BOOKSTORES_AND_NEWSSTANDS": "Bookstores and Newsstands",
    "GENERAL_MERCHANDISE_CLOTHING_AND_ACCESSORIES": "Clothing and Accessories",
    "GENERAL_MERCHANDISE_CONVENIENCE_STORES": "Convenience Stores",
    "GENERAL_MERCHANDISE_DEPARTMENT_STORES": "Department Stores",
    "GENERAL_MERCHANDISE_DISCOUNT_STORES": "Discount Stores",
    "GENERAL_MERCHANDISE_ELECTRONICS": "Electronics",
    "GENERAL_MERCHANDISE_GIFTS_AND_NOVELTIES": "Gifts and Novelties",
    "GENERAL_MERCHANDISE_OFFICE_SUPPLIES": "Office Supplies",
    "GENERAL_MERCHANDISE_ONLINE_MARKETPLACES": "Online Marketplaces",
    "GENERAL_MERCHANDISE_PET_SUPPLIES": "Pet Supplies",
    "GENERAL_MERCHANDISE_SPORTING_GOODS": "Sporting Goods",
    "GENERAL_MERCHANDISE_SUPERSTORES": "Superstores",
    "GENERAL_MERCHANDISE_TOBACCO_AND_VAPE": "Tobacco and Vape",
    "GENERAL_MERCHANDISE_OTHER_GENERAL_MERCHANDISE": "Other General Merchandise",
    
    "HOME_IMPROVEMENT_FURNITURE": "Furniture",
    "HOME_IMPROVEMENT_HARDWARE": "Hardware",
    "HOME_IMPROVEMENT_REPAIR_AND_MAINTENANCE": "Repair and Maintenance",
    "HOME_IMPROVEMENT_SECURITY": "Security",
    "HOME_IMPROVEMENT_OTHER_HOME_IMPROVEMENT": "Other Home Improvement",
    
    "MEDICAL_DENTAL_CARE": "Dental Care",
    "MEDICAL_EYE_CARE": "Eye Care",
    "MEDICAL_NURSING_CARE": "Nursing Care",
    "MEDICAL_PHARMACIES_AND_SUPPLEMENTS": "Pharmacies and Supplements",
    "MEDICAL_PRIMARY_CARE": "Primary Care",
    "MEDICAL_VETERINARY_SERVICES": "Veterinary Services",
    "MEDICAL_OTHER_MEDICAL": "Other Medical",
    
    "PERSONAL_CARE_GYMS_AND_FITNESS_CENTERS": "Gyms and Fitness Centers",
    "PERSONAL_CARE_HAIR_AND_BEAUTY": "Hair and Beauty",
    "PERSONAL_CARE_LAUNDRY_AND_DRY_CLEANING": "Laundry and Dry Cleaning",
    "PERSONAL_CARE_OTHER_PERSONAL_CARE": "Other Personal Care",
    
    "GENERAL_SERVICES_ACCOUNTING_AND_FINANCIAL_PLANNING": "Accounting and Financial Planning",
    "GENERAL_SERVICES_AUTOMOTIVE": "Automotive",
    "GENERAL_SERVICES_CHILDCARE": "Childcare",
    "GENERAL_SERVICES_CONSULTING_AND_LEGAL": "Consulting and Legal",
    "GENERAL_SERVICES_EDUCATION": "Education",
    "GENERAL_SERVICES_INSURANCE": "Insurance",
    "GENERAL_SERVICES_POSTAGE_AND_SHIPPING": "Postage and Shipping",
    "GENERAL_SERVICES_STORAGE": "Storage",
    "GENERAL_SERVICES_OTHER_GENERAL_SERVICES": "Other General Services",
    
    "GOVERNMENT_AND_NON_PROFIT_DONATIONS": "Donations",
    "GOVERNMENT_AND_NON_PROFIT_GOVERNMENT_DEPARTMENTS_AND_AGENCIES": "Government Departments and Agencies",
    "GOVERNMENT_AND_NON_PROFIT_TAX_PAYMENT": "Tax Payment",
    "GOVERNMENT_AND_NON_PROFIT_OTHER_GOVERNMENT_AND_NON_PROFIT": "Other Government and Non Profit",
    
    "TRANSPORTATION_BIKES_AND_SCOOTERS": "Bikes and Scooters",
    "TRANSPORTATION_GAS": "Gas",
    "TRANSPORTATION_PARKING": "Parking",
    "TRANSPORTATION_PUBLIC_TRANSIT": "Public Transit",
    "TRANSPORTATION_TAXIS_AND_RIDE_SHARES": "Taxis and Ride Shares",
    "TRANSPORTATION_TOLLS": "Tolls",
    "TRANSPORTATION_OTHER_TRANSPORTATION": "Other Transportation",
    
    "TRAVEL_FLIGHTS": "Flights",
    "TRAVEL_LODGING": "Lodging",
    "TRAVEL_RENTAL_CARS": "Rental Cars",
    "TRAVEL_OTHER_TRAVEL": "Other Travel",
    
    "RENT_AND_UTILITIES_GAS_AND_ELECTRICITY": "Gas and Electricity",
    "RENT_AND_UTILITIES_INTERNET_AND_CABLE": "Internet and Cable",
    "RENT_AND_UTILITIES_RENT": "Rent",
    "RENT_AND_UTILITIES_SEWAGE_AND_WASTE_MANAGEMENT": "Sewage and Waste Management",
    "RENT_AND_UTILITIES_TELEPHONE": "Telephone",
    "RENT_AND_UTILITIES_WATER": "Water",
    "RENT_AND_UTILITIES_OTHER_UTILITIES": "Other Utilities"
]

let categoryTypeMapping: [String: String] = [
    "INCOME": "Income",
    "TRANSFER_IN": "Transfer In",
    "TRANSFER_OUT": "Transfer Out",
    "LOAN_PAYMENTS": "Loan Payments",
    "BANK_FEES": "Bank Fees",
    "ENTERTAINMENT": "Entertainment",
    "FOOD_AND_DRINK": "Food And Drink",
    "GENERAL_MERCHANDISE": "General Merchandise",
    "HOME_IMPROVEMENT": "Home Improvement",
    "MEDICAL": "Medical",
    "PERSONAL_CARE": "Personal Care",
    "GENERAL_SERVICES": "General Services",
    "GOVERNMENT_AND_NON_PROFIT": "Government And Non Profit",
    "TRANSPORTATION": "Transportation",
    "TRAVEL": "Travel",
    "RENT_AND_UTILITIES": "Rent And Utilities"
]


