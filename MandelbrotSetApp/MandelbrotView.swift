//
//  ContentView.swift
//  MandelbrotSetApp
//
//  Created by Himanshu Sherkar on 21/10/26.
//

import SwiftUI
import Combine
import Foundation

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
                .float(palette.rawValue),
                .float(Float(iterationLimit))
            ))
            .onGeometryChange(for: CGFloat.self, of: \.size.width) { viewWidth = $0 }
            .gesture(panGesture)
            .simultaneousGesture(magnificationGesture)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                palettePicker
                    .padding(.leading, 16)
                    .padding(.top, 12)
                    .safeAreaPadding(.top)
            }
            .overlay(alignment: .bottomLeading) {
                playbackControls
                    .padding(.leading, 16)
                    .padding(.bottom, 12)
                    .safeAreaPadding(.bottom)
            }
            .overlay(alignment: .bottomTrailing) {
                zoomSpeedControls
                    .padding(.trailing, 16)
                    .padding(.bottom, 12)
                    .safeAreaPadding(.bottom)
            }
            .onReceive(Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()) { _ in
                guard isAutoZooming else { return }

                let updatedSpan = horizontalSpan * pow(baseZoomRate, zoomSpeed / 60)

                if updatedSpan <= minimumRenderableSpan {
                    resetViewport()
                } else {
                    horizontalSpan = updatedSpan
                    currentSpan = updatedSpan
                }
            }
    }

    private var minimumRenderableSpan: CGFloat {
        max(0.000_05, viewWidth * 0.000_000_15)
    }

    private var iterationLimit: Int {
        let zoomLevels = log2(Double(initialSpan / max(horizontalSpan, minimumRenderableSpan)))
        return min(1_024, 256 + Int(max(0, zoomLevels) * 64))
    }

    private var panGesture: some Gesture {
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
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
//                isAutoZooming = false
                horizontalSpan = min(max(currentSpan / value.magnification, minimumRenderableSpan), initialSpan)
            }
            .onEnded { _ in
                currentSpan = horizontalSpan
            }
    }

    private var palettePicker: some View {
        Picker("Colour palette", selection: $palette) {
            ForEach(MandelbrotPalette.allCases) { palette in
                Text(palette.name).tag(palette)
            }
        }
        .pickerStyle(.menu)
        .padding(5)
        .glassEffect(.regular.interactive(), in: Capsule())
    }

    private var playbackControls: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    isAutoZooming.toggle()
                } label: {
                    Image(systemName: isAutoZooming ? "pause.fill" : "play.fill")
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.glass)
                .accessibilityLabel(isAutoZooming ? "Pause automatic zoom" : "Play automatic zoom")

                Button {
                    isAutoZooming = false
                    resetViewport()
                    zoomSpeed = 1
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Reset viewport and zoom speed")
            }
        }
    }

    private var zoomSpeedControls: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    zoomSpeed = max(zoomSpeed - 0.25, minimumZoomSpeed)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.glass)
                .disabled(zoomSpeed == minimumZoomSpeed)
                .accessibilityLabel("Decrease zoom speed")

                Button {
                    zoomSpeed = min(zoomSpeed + 0.25, maximumZoomSpeed)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.glass)
                .disabled(zoomSpeed == maximumZoomSpeed)
                .accessibilityLabel("Increase zoom speed")
            }
        }
    }

    private func resetViewport() {
        center = initialCenter
        currentCenter = initialCenter
        horizontalSpan = initialSpan
        currentSpan = initialSpan
    }
}

#Preview {
    MandelbrotView()
}
