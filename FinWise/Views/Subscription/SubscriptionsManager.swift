//
//  SubscriptionsManager.swift
//  FinWise
//
//  Created by Parth Modi on 2024-10-10.
//

import SwiftUI
import StoreKit

@MainActor @Observable
class SubscriptionsManager {
    let productIDs: [String] = ["finwise_1999_1m", "finwise_19999_12m"]
    var purchasedProductIDs: Set<String> = []

    var products: [Product] = []

    private var entitlementManager: EntitlementManager? = nil
    @ObservationIgnored private var updates: Task<Void, Never>? = nil

    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        self.updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // Load available products
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs).sorted(by: { $0.price > $1.price })
        } catch {
            print("Failed to fetch products!")
        }
    }

    // Observe subscription updates
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in StoreKit.Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }

    // Check and update current purchased products
    func updatePurchasedProducts() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }

        self.entitlementManager?.hasPro = !self.purchasedProductIDs.isEmpty
    }

    // Purchase a product
    func buyProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(.verified(transaction)):
                await transaction.finish()
                await self.updatePurchasedProducts()
            case .pending, .userCancelled, .success(.unverified(_, _)):
                break
            @unknown default:
                break
            }
        } catch {
            print("Failed to purchase the product!")
        }
    }
}

