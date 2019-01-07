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

float map(float value, float min1, float max1, float min2, float max2) 
{
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}





void main()
 {
     
    vec3 green = vec3(0.0, 1.0, 0.4);
    vec4 origColor = texture2D( texture, vertTexCoord.st);
        
    vec2 currentPos =  vec2(gl_FragCoord.x, resolution.y - gl_FragCoord.y);
    
   
    float dist = distance(mousePos, currentPos);
    
    //convert to ss
    dist = dist / resolution.x;
    
    float sm = radius * 5;
    
    float vignette = smoothstep(radius, sm, dist);
    
    green *= 1 - vignette;
    
    origColor.rgb += mix(origColor.rgb, green, 0.8);
    

    gl_FragColor = origColor;
 
 }