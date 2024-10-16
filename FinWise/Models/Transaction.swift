//
//  Transaction.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var id: String? = UUID().uuidString
    var name: String? = ""
    var category: Category? = nil
    var date: Date? = Date()
    var amount: Double? = 0.0
    var currencyCode: String? = "USD"
    var account: Account? = nil

    init(id: String? = UUID().uuidString, name: String? = "", category: Category? = nil, date: Date? = Date(), amount: Double? = 0.0, currencyCode: String? = "USD", account: Account? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.date = date
        self.amount = amount
        self.currencyCode = currencyCode
        self.account = account
    }
}

