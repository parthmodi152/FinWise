//
//  SpendingChart.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import SwiftUI

struct SpendingChart: View {
    let bgColor: Color
    let amount: Double
    let categoryName: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(categoryName)
                
                HStack(spacing: 2) {
                    Text("$\(amount, specifier: "%.0f")") // Main amount
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(".\(String(format: "%.2f", amount).components(separatedBy: ".").last!)") // Decimal amount
                        .font(.headline)
                        .fontWeight(.bold)
                        .baselineOffset(-8) // Align with the main amount
                }
                .padding(.top, 5)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text("$\(amount, specifier: "%.0f")") // Main amount
                        .font(.title)
                        .fontWeight(.medium)
                    
                    Text(".\(String(format: "%.2f", amount).components(separatedBy: ".").last!)") // Decimal amount
                        .font(.footnote)
                        .fontWeight(.medium)
                        .baselineOffset(-8) // Align with the main amount
                }
                .padding(.bottom, 5)
            }
            
            Spacer()
            
            ProgressBar(rotate: true)
        }
        .frame(width: 300, height: 300)
        .padding()
        .background(bgColor.gradient.opacity(0.8))
        .cornerRadius(35)
    }
}

#Preview {
    SpendingChart(bgColor: .color2, amount: 23000.62, categoryName: "Home Expense")
}
