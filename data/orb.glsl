#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
 
#define PROCESSING_TEXTURE_SHADER
 
uniform sampler2D texture;

// The inverse of the texture dimensions along X and Y
uniform vec2 texOffset;
 
varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform vec2 resolution;
uniform vec2 mousePos;
uniform float radius;
uniform float time;



// Some useful functions
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289((x*30. + 1.0 + (time/10000.))*x);  }

//
// Description : GLSL 2D simplex noise function
//      Author : Ian McEwan, Ashima Arts
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License :
//  Copyright (C) 2011 Ashima Arts. All rights reserved.
//  Distributed under the MIT License. See LICENSE file.
//  https://github.com/ashima/webgl-noise
//
float snoise(vec2 v) {
    
    // Precompute values for skewed triangular grid
    const vec4 C = vec4(0.211324865405187,
                        // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,
                        // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,
                        // -1.0 + 2.0 * C.x
                        0.024390243902439);
    // 1.0 / 41.0
    
    // First corner (x0)
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    
    // Other two corners (x1, x2)
    vec2 i1 = vec2(0.0);
    i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
    vec2 x1 = x0.xy + C.xx - i1;
    vec2 x2 = x0.xy + C.zz;
    
    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    vec3 p = permute(
                     permute( i.y + vec3(0.0, i1.y, 1.0))
                     + i.x + vec3(0.0, i1.x, 1.0 ));
    
    vec3 m = max(0.5 - vec3(
                            dot(x0,x0),
                            dot(x1,x1),
                            dot(x2,x2)
                            ), 0.0);
    
    m = m*m ;
    m = m*m ;
    
    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)
    
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);
    
    // Compute final noise value at P
    vec3 g = vec3(0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
    return 130.0 * dot(m, g);
}

#define OCTAVES 4
float turbulence (in vec2 st) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * abs(snoise(st));
        st *= 2.;
        amplitude *= 0.500;
    }
    return value;
}

void main()
{
    vec3 green = vec3(0.0, 1.0, 0.4);
    vec4 origColor = texture2D( texture, vertTexCoord.st);
    
    
    
    vec2 currentPos = gl_FragCoord.xy / resolution.xy;
    currentPos.x *= resolution.x/resolution.y;
    
    vec2 mouse = mousePos.xy / resolution.xy;
    mouse = vec2(mouse.x, 1.0 - mouse.y);
    mouse.x *= resolution.x / resolution.y;
    
    
    float dist = distance(mouse, currentPos);
    
    float rad = radius / resolution.x * 1.5;
    float smo = rad * 5.0;
    
    float maskRadius = rad * 8.0;
    float maskSmooth = maskRadius * 3.0;
    
    float renderRadius = maskRadius + maskSmooth + 0.01;
    
    
    if ( dist < renderRadius)
    {
        // VIGNETTE
        float vignette = smoothstep(rad, smo, dist);
        
        // WATER MASK
        float mask = 1.0 - smoothstep(maskRadius, maskSmooth, dist);
        
        
        // DISPLACEMENT
        vec2 uv = gl_FragCoord.xy / resolution.xy;
        float X = uv.x * 10. + time;
        float Y = uv.y * 10. + time;
        uv.y += cos(X+Y) * 0.01 * cos(Y) * mask;
        uv.x += sin(X-Y) * 0.01 * sin(Y) * mask;
        
        origColor = texture2D( texture, uv.st);
        
        
        // 6.0 scale
        float scale = 6.0;
        green *= vec3( turbulence(uv * 6.0) );
        
        
        green *= 1.0 - vignette;
        
        origColor.rgb += mix(origColor.rgb, green, 0.8);
    }
    
    origColor = clamp(origColor, 0.0, 1.0);
    
    
    
    gl_FragColor = origColor;
    
}
