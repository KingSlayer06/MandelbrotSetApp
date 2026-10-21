//
//  ContentView.swift
//  MandelbrotSetApp
//
//  Created by Himanshu Sherkar on 21/10/26.
//

import SwiftUI
import Combine
import Foundation

private enum MandelbrotPalette: Float, CaseIterable, Identifiable {
    case aurora
    case ocean
    case sunset
    case monochrome
    case glacier
    case ember
    case orchid
    case forest
    case sepia
    case neon

    var id: Self { self }

    var name: String {
        switch self {
        case .aurora: "Aurora"
        case .ocean: "Ocean"
        case .sunset: "Sunset"
        case .monochrome: "Monochrome"
        case .glacier: "Glacier"
        case .ember: "Ember"
        case .orchid: "Orchid"
        case .forest: "Forest"
        case .sepia: "Sepia"
        case .neon: "Neon"
        }
    }
}

struct MandelbrotView: View {
    private let initialCenter = CGPoint(x: -0.6, y: 0.0)
    private let initialSpan: CGFloat = 5.5
    private let baseZoomRate: CGFloat = 0.72
    private let minimumZoomSpeed: CGFloat = 0.25
    private let maximumZoomSpeed: CGFloat = 3

    @State private var center = CGPoint(x: -0.6, y: 0.0)
    @State private var currentCenter = CGPoint(x: -0.6, y: 0.0)
    @State private var viewWidth: CGFloat = 1000
    @State private var horizontalSpan: CGFloat = 5.5
    @State private var currentSpan: CGFloat = 5.5
    @State private var palette: MandelbrotPalette = .aurora
    @State private var isAutoZooming = false
    @State private var zoomSpeed: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .fill(ShaderLibrary.mandelbrot(
                .boundingRect,
                .float2(center),
                .float(Float(horizontalSpan)),
                .float(palette.rawValue)
            ))
            .onGeometryChange(for: CGFloat.self, of: \.size.width) { viewWidth = $0 }
            .gesture(panGesture)
            .simultaneousGesture(magnificationGesture)
            .ignoresSafeArea()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                controls
            }
            .onReceive(Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()) { _ in
                guard isAutoZooming else { return }

                let zoomStep = pow(baseZoomRate, zoomSpeed / 60)
                horizontalSpan = max(horizontalSpan * zoomStep, 0.000_001)
                currentSpan = horizontalSpan
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
//                isAutoZooming = false
                let unitsPerPoint = horizontalSpan / viewWidth
                center = CGPoint(
                    x: currentCenter.x - value.translation.width * unitsPerPoint,
                    y: currentCenter.y - value.translation.height * unitsPerPoint
                )
            }
            .onEnded { _ in
                currentCenter = center
            }
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
//                isAutoZooming = false
                horizontalSpan = min(max(currentSpan / value.magnification, 0.000_001), initialSpan)
            }
            .onEnded { _ in
                currentSpan = horizontalSpan
            }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack {
                Picker("Colour palette", selection: $palette) {
                    ForEach(MandelbrotPalette.allCases) { palette in
                        Text(palette.name).tag(palette)
                    }
                }
                .pickerStyle(.menu)

                Spacer(minLength: 0)

                zoomSpeedControls
            }

            HStack(spacing: 12) {
                Button {
                    isAutoZooming.toggle()
                } label: {
                    Label(isAutoZooming ? "Pause" : "Play", systemImage: isAutoZooming ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint(isAutoZooming ? "Pauses automatic zoom" : "Starts automatic zoom")

                Button {
                    isAutoZooming = false
                    center = initialCenter
                    currentCenter = initialCenter
                    horizontalSpan = initialSpan
                    currentSpan = initialSpan
                    zoomSpeed = 1
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var zoomSpeedControls: some View {
        HStack(spacing: 4) {
            Button {
                zoomSpeed = max(zoomSpeed - 0.25, minimumZoomSpeed)
            } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.bordered)
            .disabled(zoomSpeed == minimumZoomSpeed)
            .accessibilityLabel("Decrease zoom speed")

            Text("\(zoomSpeed, specifier: "%.2g")×")
                .font(.subheadline.monospacedDigit())
                .frame(minWidth: 32)
                .accessibilityLabel("Zoom speed \(zoomSpeed, specifier: "%.2g") times")

            Button {
                zoomSpeed = min(zoomSpeed + 0.25, maximumZoomSpeed)
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.bordered)
            .disabled(zoomSpeed == maximumZoomSpeed)
            .accessibilityLabel("Increase zoom speed")
        }
    }
}

#Preview {
    MandelbrotView()
}
