//
//  ContentView.swift
//  MandelbrotSetApp
//
//  Created by Himanshu Sherkar on 21/10/26.
//

import SwiftUI

struct MandelbrotView: View {
    @State private var center = CGPoint(x: -0.6, y: 0.0)
    @State private var currentCenter = CGPoint(x: -0.6, y: 0.0)
    @State private var viewWidth: CGFloat = 1000
    @State private var horizontalSpan: CGFloat = 5.5
    @State private var currentSpan: CGFloat = 5.5
    
    var body: some View {
        Rectangle()
            .fill(ShaderLibrary.mandelbrot(
                .boundingRect,
                .float2(center),
                .float(Float(horizontalSpan))
            ))
            .onGeometryChange(for: CGFloat.self, of: \.size.width) {
                viewWidth = $0
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let unitsPerPoint = horizontalSpan / viewWidth
                        center = CGPoint(
                            x: currentCenter.x - value.translation.width * unitsPerPoint,
                            y: currentCenter.y - value.translation.height * unitsPerPoint
                        )
                    }
                    .onEnded { _ in
                        currentCenter = center
                    }
            )
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { value in
                        horizontalSpan = min(max(currentSpan / value.magnification, 0.000_01), 5.5)
                    }
                    .onEnded { _ in
                        currentSpan = horizontalSpan
                    }
            )
            .ignoresSafeArea()
    }
}

#Preview {
    MandelbrotView()
}
