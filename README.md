# Mandelbrot Set Explorer

An iOS Mandelbrot-set explorer built with SwiftUI and Metal.

![Blue and gold rendering of the Mandelbrot set](https://upload.wikimedia.org/wikipedia/commons/a/a4/Blue-Gold_Mandelbrot_Set.jpg)

## What is the Mandelbrot set?

The Mandelbrot set is a fractal made by repeatedly applying `zₙ₊₁ = zₙ² + c` to points on the complex plane. Points that stay bounded form the black part of the set; escaped points are coloured by how quickly they diverge.

Learn more on [Wikipedia](https://en.wikipedia.org/wiki/Mandelbrot_set).

## Features

- Drag and pinch to explore the fractal.
- Choose from ten colour palettes.
- Play, pause, reset, and change automatic-zoom speed.
- Supports the iPhone Duo right-side toolbar for controls using the new SwiftUI APIs.
- Restarts automatic zoom before GPU `float` precision causes blocky artefacts.

## How it works

Each screen pixel represents one point on the complex plane. The Metal shader evaluates those pixels independently, allowing the GPU to render many Mandelbrot calculations in parallel. Each pixel's iteration loop remains sequential.

SwiftUI handles gestures, palette selection, and zoom controls. Metal calculates the fractal colours.

## Run it

1. Open `MandelbrotSetApp.xcodeproj` in Xcode.
2. Select an iOS simulator or device.
3. Build and run the `MandelbrotSetApp` scheme.

## Credit

Inspired by [Maths + Metal: Mandelbrot](https://blog.jacobstechtavern.com/p/maths-metal-mandelbrot) by Jacob's Tech Tavern.
