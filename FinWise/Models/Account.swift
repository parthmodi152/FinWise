//
//  Account.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import Foundation

import Foundation
import SwiftData

enum AccountType: String, CaseIterable, Codable {
    case cash = "Cash"
    case depository = "Depository"
    case credit = "Credit"
    case split = "Split"
}

@Model
final class Account {
    var id: String?
    var name: String?
    var type: AccountType?
    var balance: Double?
    var currencyCode: String?
    var bankName: String?
    var mask: String?
    @Relationship(deleteRule: .nullify, inverse: \Transaction.account) var transactions: [Transaction]?

    init(id: String? = UUID().uuidString, name: String? = "", balance: Double? = 0.0, type: AccountType? = .cash, currencyCode: String? = "USD", bankName: String? = "", transactions: [Transaction]? = [Transaction](), mask: String? = "") {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.currencyCode = currencyCode
        self.bankName = bankName
        self.mask = mask
        self.transactions = transactions
    }
}
