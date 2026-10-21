//
//  MandelbrotSet.metal
//  MandelbrotSetApp
//
//  Created by Himanshu Sherkar on 21/10/26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

half3 palette(int iterations) {
    float phase = 0.15 * float(iterations);
    return half3(
        0.5 + 0.5 * cos(phase + 4.0),
        0.5 + 0.5 * cos(phase + 2.0),
        0.5 + 0.5 * cos(phase)
    );
}

[[ stitchable ]]
half4 mandelbrot(
      float2 position,
      float4 bounds,
      float2 center,
      float horizontalSpan
) {
    float2 size = bounds.zw;
    float2 offset = position - bounds.xy - size * 0.5;
    
    float unitsPerPoint = horizontalSpan / size.x;
    float2 c = center + offset * unitsPerPoint;
    
    float2 z = float2(0.0, 0.0);
    const int maxIterations = 256;
    int iterations = 0;
    
    for (; iterations < maxIterations; iterations++) {
        z = float2(
            z.x * z.x - z.y * z.y,
            2.0 * z.x * z.y
        ) + c;
        
        if (length(z) > 2.0) {
            break;
        }
    }
    
    if (iterations == maxIterations) {
        return half4(0.0h, 0.0h, 0.0h, 1.0h);
    }
    
    return half4(palette(iterations), 1.0h);
}
