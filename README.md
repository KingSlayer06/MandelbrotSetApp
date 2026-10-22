# Mandelbrot Set Explorer

An iOS Mandelbrot-set explorer app built with SwiftUI and Metal. Pan across the complex plane, pinch to zoom, choose a colour palette, or start an automatic zoom.

![Blue and gold rendering of the Mandelbrot set](https://upload.wikimedia.org/wikipedia/commons/a/a4/Blue-Gold_Mandelbrot_Set.jpg)

## What is the Mandelbrot set?

The Mandelbrot set is a collection of points in the complex plane. For each point `c`, the app repeatedly applies this equation:

```text
z₀ = 0
zₙ₊₁ = zₙ² + c
```

If the values of `z` stay bounded, the point belongs to the set. If they grow without limit, the point lies outside it. Mapping this test across a grid of points produces the familiar black shape and its infinitely detailed boundary.

For a deeper mathematical explanation, see the [Mandelbrot set article on Wikipedia](https://en.wikipedia.org/wiki/Mandelbrot_set).

## Features

- Explore the set with drag and pinch gestures.
- Choose from ten colour palettes, including Aurora, Glacier, Ember, Forest, and Neon.
- Start, pause, or reset automatic zoom.
- Adjust automatic-zoom speed from `0.25×` to `3×`.
- Automatically restart the zoom at a precision-safe depth.

## How it works

### SwiftUI provides the camera and controls

`MandelbrotView` stores the viewport centre and horizontal span. A `DragGesture` moves the centre, while a `MagnifyGesture` changes the span. Those values, together with the selected palette and iteration limit, are passed into the Metal shader through `ShaderLibrary.mandelbrot`.

The bottom controls are regular SwiftUI views. A timer advances the horizontal span during auto zoom; when the view reaches the safe zoom limit, it returns to the initial viewport and continues the animation.

### Metal renders one complex point per pixel

The stitchable `mandelbrot` shader maps each display pixel to a complex number:

1. It converts the pixel's offset from the view centre into complex-plane coordinates.
2. It evaluates `z = z² + c` until the value escapes or reaches its iteration limit.
3. It colours escaped points according to their escape time and renders points that do not escape as black.

The iteration limit rises from 256 to 1,024 as the zoom gets deeper, preserving more detail where it is needed. The shader uses smooth escape-time colouring rather than only whole iteration counts, which keeps transitions between palette colours smooth.

### Colour palettes

Each palette maps escape time to RGB colour in Metal. The app includes both cosine-based palettes and multi-stop colour ramps. Because the colour is derived from the escape time, the palette remains responsive as the viewport changes.

### Deep-zoom boundary

The renderer uses GPU `float` coordinates. At an extreme zoom, adjacent display pixels can no longer represent distinct complex-plane coordinates, which causes blocky artefacts. The app therefore limits zoom based on the current view width and restarts automatic zoom before that precision limit is reached.

## Run the project

1. Open [MandelbrotSetApp.xcodeproj](MandelbrotSetApp.xcodeproj) in Xcode.
2. Select an iOS simulator or connected device.
3. Build and run the `MandelbrotSetApp` scheme.

The project targets iOS 27.0 and uses only SwiftUI and Metal frameworks.

## Project structure

```text
MandelbrotSetApp/
├── MandelbrotView.swift      # SwiftUI camera, gestures, palettes, and controls
├── MandelbrotSet.metal       # Metal Mandelbrot and colour-rendering shader
└── MandelbrotSetAppApp.swift # App entry point
```
