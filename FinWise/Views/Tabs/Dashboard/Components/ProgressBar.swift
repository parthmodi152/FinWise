//
//  ProgressBar.swift
//  Finwise
//
//  Created by Parth Modi on 2024-08-29.
//

import SwiftUI

struct ProgressBar: View {
    private var length: CGFloat
    private var thickness: CGFloat
    private var progress: Double
    private var rotate: Bool
    private var progressBgColor: Color
    private var progressBarColor: Color
    
    private var width: CGFloat {
        rotate ? thickness : length
    }
    
    private var height: CGFloat {
        rotate ? length : thickness
    }
    
    struct Stripes: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.size.width
            let height = rect.size.height
            
            for x in stride(from: 0, through: width, by: width / (0.4 * height)) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: height))
            }
            return path
        }
    }
    
    var body: some View {
        
        ZStack {
            // Draw the stripes clipped to the shape
            Stripes()
                .stroke(lineWidth: 3)
                .frame(width: length, height: thickness)
                .fixedSize()
                .clipShape(Capsule())
                .rotationEffect(rotate ? .degrees(-90) : .degrees(0))
                .foregroundColor(progressBgColor)
            
            // Draw the shape outline
            Capsule()
                .frame(width: progress * length, height: thickness)
                .fixedSize()
                .rotationEffect(rotate ? .degrees(-90) : .degrees(0))
                .offset(x: rotate ? 0 : (1 - 0.75) * (-0.5 * length), y: rotate ? (1 - 0.75) * (0.5 * length) : 0)
                .foregroundColor(progressBarColor)
            
            HStack() {
                Image(systemName: "gear")
                    .frame(width: 55, height: 55)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.primary)
                
            }
            .frame(width: progress * length, height: thickness)
            .offset(x: rotate ? 0 : (1 - 0.75) * (-0.5 * length), y: rotate ? (1 - 0.75) * (0.5 * length) : 0)
        }
        .frame(width: width, height: height)
        .fixedSize()
    }
    
    init(length: CGFloat = 300, thickness: CGFloat = 100, progress: Double = 0.75, rotate: Bool = false, progressBgColor: Color = .gray, progressBarColor: Color = .color1) {
        self.length = length
        self.thickness = thickness
        self.progress = progress
        self.rotate = rotate
        self.progressBgColor = progressBgColor
        self.progressBarColor = progressBarColor
    }
}

#Preview {
    ProgressBar()
}
