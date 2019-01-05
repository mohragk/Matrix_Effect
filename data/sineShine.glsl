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


uniform float amplitude;
uniform float time; 

float pi = 3.141592;
 
 vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
 
 
 void main()
 {
     vec3 color = vec3( 0.0, 0.0, 0.0);
     float alpha = 1.0;
     
    
    vec4 origColor = texture2D( texture, vertTexCoord.st);

    vec3 colorA = origColor.rgb;

    vec3 hsvColorA = rgb2hsv(colorA);


    hsvColorA.g = 1.0 - (amplitude * 1 * abs(cos(time * pi * 0.5)));


    color = hsv2rgb(hsvColorA);
    
    
    
   
    
    gl_FragColor = vec4(color, alpha);
 
 }
 
