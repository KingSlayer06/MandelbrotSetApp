//
//  MandelbrotSet.metal
//  MandelbrotSetApp
//
//  Created by Himanshu Sherkar on 21/10/26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

float3 colourRamp(float position, float3 first, float3 second, float3 third, float3 fourth) {
    float t = clamp(position, 0.0, 1.0);

    if (t < 1.0 / 3.0) {
        return mix(first, second, t * 3.0);
    }

    if (t < 2.0 / 3.0) {
        return mix(second, third, (t - 1.0 / 3.0) * 3.0);
    }

    return mix(third, fourth, (t - 2.0 / 3.0) * 3.0);
}

half3 palette(int iterations, float paletteIndex) {
    float phase = 0.15 * float(iterations);

    if (paletteIndex < 0.5) {
        return half3(
            0.5 + 0.5 * cos(phase + 4.0),
            0.5 + 0.5 * cos(phase + 2.0),
            0.5 + 0.5 * cos(phase)
        );
    }

    if (paletteIndex < 1.5) {
        return half3(
            0.1 + 0.2 * cos(phase + 2.4),
            0.5 + 0.5 * cos(phase + 1.2),
            0.6 + 0.4 * cos(phase)
        );
    }

    if (paletteIndex < 2.5) {
        return half3(
            0.6 + 0.4 * cos(phase),
            0.2 + 0.35 * cos(phase + 2.0),
            0.08 + 0.2 * cos(phase + 4.0)
        );
    }

    if (paletteIndex < 3.5) {
        float shade = 0.15 + 0.85 * (0.5 + 0.5 * cos(phase));
        return half3(shade);
    }

    float rampPosition = fract(float(iterations) * 0.022);

    if (paletteIndex < 4.5) {
        return half3(colourRamp(rampPosition,
            float3(0.01, 0.04, 0.12),
            float3(0.03, 0.28, 0.46),
            float3(0.20, 0.78, 0.84),
            float3(0.90, 0.98, 1.00)
        ));
    }

    if (paletteIndex < 5.5) {
        return half3(colourRamp(rampPosition,
            float3(0.10, 0.01, 0.01),
            float3(0.48, 0.04, 0.01),
            float3(0.96, 0.27, 0.01),
            float3(1.00, 0.88, 0.42)
        ));
    }

    if (paletteIndex < 6.5) {
        return half3(colourRamp(rampPosition,
            float3(0.07, 0.01, 0.18),
            float3(0.34, 0.05, 0.52),
            float3(0.82, 0.24, 0.74),
            float3(1.00, 0.72, 0.91)
        ));
    }

    if (paletteIndex < 7.5) {
        return half3(colourRamp(rampPosition,
            float3(0.01, 0.08, 0.05),
            float3(0.04, 0.28, 0.16),
            float3(0.26, 0.56, 0.13),
            float3(0.76, 0.85, 0.31)
        ));
    }

    if (paletteIndex < 8.5) {
        return half3(colourRamp(rampPosition,
            float3(0.10, 0.05, 0.02),
            float3(0.36, 0.18, 0.06),
            float3(0.69, 0.42, 0.16),
            float3(0.96, 0.80, 0.47)
        ));
    }

    return half3(colourRamp(rampPosition,
        float3(0.01, 0.00, 0.08),
        float3(0.00, 0.78, 0.91),
        float3(0.94, 0.08, 0.88),
        float3(0.98, 0.95, 0.16)
    ));
}

[[ stitchable ]]
half4 mandelbrot(
      float2 position,
      float4 bounds,
      float2 center,
      float horizontalSpan,
      float paletteIndex
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
    
    return half4(palette(iterations, paletteIndex), 1.0h);
}
