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
#define PI 3.1416

float smoothCircle(in vec2 _st, in float _radius, in float smoothness){
    vec2 dist = _st-vec2(0.5,0.5);
	return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*smoothness),
                         dot(dist,dist)*4.0);
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
        
    

    vec2 currentPos = gl_FragCoord.xy / resolution.xy; 
    currentPos.x *= resolution.x/resolution.y;
    
    vec2 mouse = mousePos.xy / resolution.xy;
    mouse = vec2(mouse.x, 1.0 - mouse.y);
    mouse.x *= resolution.x / resolution.y;

    
   

    float dist = distance(mouse, currentPos);


    float rad = radius / resolution.x;
    float smo = rad * 5.0;

    float maskRadius = rad * 8.0;
    float maskSmooth = maskRadius * 3.0;

    float renderRadius = maskRadius + maskSmooth + 0.01;

    //if ( dist < renderRadius)
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
        
        vec2 st = currentPos;
        vec2 pos = vec2(
            st.x * 145. * abs(sin(TWO_PI * time)), 
            st.y * 145. * abs(sin(TWO_PI * time))  * 10
            );
        float n = noise( pos );
        
        green.rgb += vec3(n); 
        
        green *= 1. - vignette;
        
        origColor.rgb += mix(origColor.rgb, green, 0.8);       
    }
	
    origColor = clamp(origColor, 0.0, 1.0);

    gl_FragColor = origColor;
 
 }