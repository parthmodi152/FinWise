//
//  Item.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: String? = ""
    var fullName: String? = ""
    var email: String? = ""

    init(id: String?, fullName: String?, email: String?) {
        self.id = id
        self.fullName = fullName
        self.email = email
    }
    
    // Helper function to fetch a user by ID
    static func fetchUser(byID userID: String, in context: ModelContext) -> User? {
        let predicate = #Predicate<User> { $0.id == userID }
        let descriptor = FetchDescriptor<User>(predicate: predicate)
        
        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            print("Failed to fetch user with ID \(userID): \(error)")
            return nil
        }
    }
}
