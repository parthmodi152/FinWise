//
//  AccountCard.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import SwiftUI

struct AccountCard: View {
    let accountType: String
    let amount: Double
    let iconName: String?
    let bgColor: Color
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) { // Adjust spacing as needed
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.callout)
                        .frame(width: 35, height: 35)
                        .background(Circle().fill(Color.white))
                }
                
                Text(accountType)
                    .font(.callout)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            Spacer()
            
            HStack(spacing: 1) {
                Text("$\(amount, specifier: "%.0f")") // Main amount
                    .font(.title)
                    .fontWeight(.medium)
                
                Text(".\(String(format: "%.2f", amount).components(separatedBy: ".").last!)") // Decimal amount
                    .font(.footnote)
                    .fontWeight(.medium)
                    .baselineOffset(-8) // Align with the main amount
            }
            .padding(.top, 5)
        }
        .padding()
        .frame(width: (iconName != nil) ? 180 : 160)
        .frame(maxHeight: 120)
        .background(RoundedRectangle(cornerRadius: 20).fill(bgColor))
    }
    
    init(accountType: String, amount: Double, iconName: String? = nil, bgColor: Color = .color5) {
        self.accountType = accountType
        self.amount = amount
        self.iconName = iconName
        self.bgColor = bgColor
    }
}

#Preview {
    AccountCard(accountType: "Banking", amount: 10230.20)
}
