//
//  UserHandler.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
//

import Foundation
import SwiftData
import AuthenticationServices

@MainActor
@Observable class UserHandler {
    var currentUser: User?
    private var context: ModelContext
    
    private let userIDKey = "userID"
    
    init(modelContext: ModelContext) {
        context = modelContext
        // Load the signed-in user on initialization
        loadCurrentUser()
    }
    
    func loadCurrentUser() {
        guard let userID = UserDefaults.standard.string(forKey: userIDKey), !userID.isEmpty else {
            currentUser = nil
            return
        }
        
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
            DispatchQueue.main.async {
                if case .authorized = state, let user = User.fetchUser(byID: userID, in: self.context) {
                    self.currentUser = user
                } else {
                    // User ID is no longer authorized, clear the stored ID
                    UserDefaults.standard.removeObject(forKey: self.userIDKey)
                    self.currentUser = nil
                }
            }
        }
    }
    
    func signInUser(_ userCredential: ASAuthorizationAppleIDCredential) {
        // Store userID in UserDefaults
        let userID = userCredential.user
        UserDefaults.standard.set(userID, forKey: userIDKey)
        
        // Check if the user already exists in the model context
        if User.fetchUser(byID: userID, in: context) == nil {
            // Merge givenName and familyName to create fullName
            let givenName = userCredential.fullName?.givenName ?? ""
            let familyName = userCredential.fullName?.familyName ?? ""
            let fullName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
            
            // Create and insert a new User into the model context
            let newUser = User(id: userID, fullName: fullName, email: userCredential.email)
            context.insert(newUser)
        }
        
        // Fetch and set the current user
        currentUser = User.fetchUser(byID: userID, in: context)
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: userIDKey)
        currentUser = nil
    }
    
    func isUserSignedIn() -> Bool {
        return UserDefaults.standard.string(forKey: userIDKey) != nil && currentUser != nil
    }
}

