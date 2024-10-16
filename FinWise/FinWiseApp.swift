//
//  FinWiseApp.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import FirebaseFunctions

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
//    Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
//      Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
      
    return true
  }
}

@main
struct FinWiseApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Account.self,
            Category.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
//             ONLY FOR DEV
//            do {
//                try container.mainContext.delete(model: Transaction.self)
//                try container.mainContext.delete(model: Account.self)
//                try container.mainContext.delete(model: Category.self)
//            } catch {
//                print("Failed to clear all Country and City data.")
//            }
            
            // Make sure the persistent store is empty. If it's not, return the non-empty container.
            var itemFetchDescriptor = FetchDescriptor<Category>()
            itemFetchDescriptor.fetchLimit = 1
            
            guard try container.mainContext.fetch(itemFetchDescriptor).count == 0 else { return container }
            
            // This code will only run if the persistent store is empty.
            let categories = Category.defaultCategories()
            
            for category in categories {
                container.mainContext.insert(category)
            }
            
            try? container.mainContext.save()
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    let entitlementManager = EntitlementManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(AuthenticationViewModel())
        .environment(PlaidLinkViewModel(modelContext: sharedModelContainer.mainContext))
        .environment(entitlementManager)
        .environment(SubscriptionsManager(entitlementManager: entitlementManager))
    }
}
