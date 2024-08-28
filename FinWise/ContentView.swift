//
//  ContentView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
//

import SwiftUI
import SwiftData
import AuthenticationServices

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserHandler.self) private var userHandler
    
    @AppStorage("userID")
    private var userID : String = ""
    
    @State
    private var isAuthenticated: Bool = false

    var body: some View {
        if userHandler.isUserSignedIn() {
            // Show the main content of your app if the user is authenticated
            MainView()
        } else {
            // Show the AuthView if the user is not authenticated
            AuthView { userCredential in
                userHandler.signInUser(userCredential)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
        .environment(UserHandler(modelContext: container.mainContext))
}
