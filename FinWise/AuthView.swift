//
//  AuthView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    var onSignIn: (ASAuthorizationAppleIDCredential) -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                // Logo at the top
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Adjust the size as needed
                    .padding(.top, 20)
                    .padding(.horizontal)
                Spacer()
            }
            
            VStack(alignment: .leading) {
                // Welcome message
                Text("Hello! \nWelcome to \nFinwise")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.color3) // Replace with the actual color asset
                    .multilineTextAlignment(.leading)
                    .padding()
                
                // Underline
                Rectangle()
                    .frame(width: 70, height: 4)
                    .foregroundColor(.color3)
                    .padding()
                
                
                VStack(alignment: .leading, spacing: 25) {
                    PointView(symbol: "dollarsign", title: "Transactions", subTitle: "Keep track of your earnings and expenses.")
                    
                    PointView(symbol: "chart.bar.fill", title: "Visual Charts", subTitle: "View your transactions using eye-catching graphic representations.")
                    
                    PointView(symbol: "magnifyingglass", title: "Advance Filters", subTitle: "Find the expenses you want by advance search and filtering.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
            }
            
            Spacer()
        
            
            // Sign in with Apple button
            SignInWithAppleButton(.continue, onRequest: onRequest, onCompletion: onCompletion)
                .frame(height: 50)
                .signInWithAppleButtonStyle(.black) // White text on black background
                .padding(.bottom, 50)
                .padding(.horizontal, 20)
        }
        .background(.color2)
    }
    
    /// Points View
    @ViewBuilder
    func PointView(symbol: String, title: String, subTitle: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: symbol)
                .font(.largeTitle)
                .foregroundStyle(.color3)
                .frame(width: 45)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(subTitle)
                    .foregroundStyle(.color3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
        
    private func onRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
        
    private func onCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                onSignIn(userCredential)
            }
        case .failure(let error):
            print("Authorization failed: " + error.localizedDescription)
        }
    }
}

#Preview {
    AuthView { _ in }
}
