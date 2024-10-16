//
//  OnboardingPage.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import SwiftUI

enum OnboardingPage: String, CaseIterable {
    case page1 = "dollarsign.circle"
    case page2 = "creditcard"
    case page3 = "chart.bar.xaxis.ascending.badge.clock"
    case page4 = "magnifyingglass"

    var title: String {
        switch self {
        case .page1:
            return "Welcome to FinWise"
        case .page2:
            return "Connect Multiple Accounts"
        case .page3:
            return "Track Your Analytics"
        case .page4:
            return "Quick & Easy Search"
        }
    }

    var subTitle: String {
        switch self {
        case .page1:
            return "Manage your finances seamlessly"
        case .page2:
            return "Link multiple bank accounts effortlessly"
        case .page3:
            return "Gain insights with detailed analytics"
        case .page4:
            return "Find transactions and data quickly"
        }
    }
    
    var index: CGFloat {
        switch self {
        case .page1: return 0
        case .page2: return 1
        case .page3: return 2
        case .page4: return 3
        }
    }

    /// Fetches the next page, if it's not the last page
    var nextPage: OnboardingPage {
        let index = Int(self.index) + 1
        if index < 4 {
            return OnboardingPage.allCases[index]
        }
        return self
    }

    /// Fetches the previous page, if it's not the first page
    var previousPage: OnboardingPage {
        let index = Int(self.index) - 1
        if index >= 0 {
            return OnboardingPage.allCases[index]
        }
        return self
    }

}
