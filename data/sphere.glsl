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

#define TWO_PI 6.28318530718

float map(float value, float min1, float max1, float min2, float max2) 
{
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}


vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}


void main()
 {
     
    vec3 green = vec3(0.0, 1.0, 0.4);
    vec4 origColor = texture2D( texture, vertTexCoord.st);
        
    vec2 currentPos =  vec2(gl_FragCoord.x, resolution.y - gl_FragCoord.y);
    
   
    float dist = distance(mousePos, currentPos);
    
    //convert to ss
    dist = dist / resolution.x;
    
	float rad = radius / resolution.x;
    float sm = rad * 5;

    float vignette = smoothstep(rad, sm, dist);
    
    vec2 st = gl_FragCoord.xy / resolution.xy;
    vec2 pos = vec2(
        st.x * 145 * abs(sin(TWO_PI * time)), 
        st.y * 145 * abs(sin(TWO_PI * time)) * (vignette / 10)
        );
	float n = noise( pos );
    
    green.rgb += vec3(n);
    clamp(green, 0, 1);
    
    
    
    green *= 1 - vignette;
    
    origColor.rgb += mix(origColor.rgb, green, 0.8);
    

    gl_FragColor = origColor;
 
 }