//
//  DashboardHeader.swift
//  FinWise
//
//  Created by Parth Modi on 2024-08-29.
//

import SwiftUI
import LinkKit
import SwiftData

struct DashboardHeader: View {
    let netWorth: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Net Worth")
                        .font(.headline)
                        .fontWeight(.medium)
                        .padding(.top, 5)
                    
                    HStack(spacing: 2) {
                        Text("$ \(netWorth, specifier: "%.0f")") // Main amount
                            .font(.system(size: 45))
                            .fontWeight(.bold)
                        
                        Text(".\(String(format: "%.2f", netWorth).components(separatedBy: ".").last!)") // Decimal amount
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .baselineOffset(-10) // Adjust offset to align with the main amount
                    }
                    .padding(.top, 5)
                }
                
                Spacer() // Pushes the content to the left
                
                Button(action: {
                    
                }) {
                    Image(systemName: "plus")
                        .frame(width: 5, height: 5)
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .background(Circle().fill(Color.white))
                    
                }
            }
        }
        .padding()
    }
}

#Preview {
    return DashboardHeader(netWorth: 165322.32)
}
