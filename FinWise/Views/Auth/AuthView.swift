//
//  AuthView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-28.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @State private var activePage: OnboardingPage = .page1
    @Environment(AuthenticationViewModel.self) private var authViewModel
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack {
                
                Spacer(minLength: 0)
                
                MorphingSymbolView(symbol: activePage.rawValue, config: .init(font: .system(size: 150, weight: .bold), frame: .init(width: 250, height: 200), radius: 30, foregroundColor: .color2))
                
                TextContents(size: size)
                
                Spacer(minLength: 0)
                
                IndicatorView()
                
                if activePage == .page4 {
                    /// Sign in with Apple button
                    SignInWithAppleButton(.continue, onRequest: authViewModel.handleSignInWithAppleRequest, onCompletion: authViewModel.handleSignInWithAppleCompletion)
                        .frame(height: 50)
                        .signInWithAppleButtonStyle(.white)
                        .padding(.bottom, 65)
                        .padding(.horizontal, 20)
                } else {
                    ContinueButton()
                }
                
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .top) {
                HeaderView()
            }
        }
        .background{
            Rectangle()
                .fill(.black.gradient)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    func TextContents(size: CGSize) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(OnboardingPage.allCases, id: \.rawValue) { page in
                    Text(page.title)
                        .foregroundStyle(.color6)
                        .lineLimit(1)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .kerning(1.1)
                        .frame(width: size.width)
                }
            }
            /// Sliding Left/Right based on the active Page
            .offset(x: -activePage.index * size.width)
            .animation(.smooth(duration: 0.7, extraBounce: 0.1), value: activePage)
            
            HStack(alignment: .top, spacing: 0) {
                ForEach(OnboardingPage.allCases, id: \.rawValue) { page in
                    Text(page.subTitle)
                        .foregroundStyle(.color4)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .kerning(1.1)
                        .frame(width: size.width)
                }
            }
            /// Sliding Left/Right based on the active Page
            .offset(x: -activePage.index * size.width)
            .animation(.smooth(duration: 0.9, extraBounce: 0.1), value: activePage)
        }
        .padding(.top, 15)
        .frame(width: size.width, alignment: .leading)
    }
    
    @ViewBuilder
    func IndicatorView() -> some View {
        HStack(spacing: 6) {
            ForEach(OnboardingPage.allCases, id: \.rawValue) { page in
                Capsule()
                    .fill(.white.opacity(activePage == page ? 1 : 0.4))
                    .frame(width: activePage == page ? 25 : 8, height: 8)
            }
        }
        .animation(.smooth(duration: 0.5, extraBounce: 0), value: activePage)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        HStack {
            Button {
                activePage = activePage.previousPage
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .contentShape(.rect)
            }
            .opacity(activePage != .page1 ? 1 : 0)

            Spacer(minLength: 0)

            Button("Skip") {
                activePage = .page4
            }
            .fontWeight(.semibold)
            .opacity(activePage != .page4 ? 1 : 0)
        }
        .foregroundStyle(.white)
        .animation(.snappy(duration: 0.35, extraBounce: 0), value: activePage)
        .padding(15)
    }



    /// Continue Button
    @ViewBuilder
    func ContinueButton() -> some View {
        Button {
            activePage = activePage.nextPage
        } label: {
            // Regular continue button for other pages
            Text(buttonLabel(for: activePage))
                        .font(.system(size: 17, weight: .semibold))
                .contentTransition(.identity)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(6)
                .padding(.bottom, 50)
                .padding(.horizontal, 20)
                .foregroundStyle(.black)
        }
        .padding(.bottom, 15)
        .animation(.smooth(duration: 0.5, extraBounce: 0), value: activePage)
    }
    
    /// Function to return quirky labels for each page
    func buttonLabel(for page: OnboardingPage) -> String {
        switch page {
        case .page1:
            return "🚀 Let’s Get Started"
        case .page2:
            return "🏦 Connect Your Banks"
        case .page3:
            return "📊 See Your Insights"
        case .page4:
            return "Continue"
        }
    }
}

#Preview {
    AuthView()
        .environment(AuthenticationViewModel())
}
