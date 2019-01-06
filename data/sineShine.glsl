#ifdef GL_ES
precision highp float;
precision highp int;
#endif
 
#define PROCESSING_TEXTURE_SHADER
 
uniform sampler2D texture;

// The inverse of the texture dimensions along X and Y
uniform vec2 texOffset;
 
varying vec4 vertColor;
varying vec4 vertTexCoord;


uniform float amplitude;
uniform float time; 
uniform float brightness;

float pi = 3.141592;

vec3 rgb2hsb( in vec3 c ){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}


vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}


 
 
 void main()
 {
     vec3 color = vec3( 0.0, 0.0, 0.0);
     float alpha = 1.0;
     
    
    vec4 origColor = texture2D( texture, vertTexCoord.st);

    vec3 colorA = origColor.rgb;

    vec3 hsvColorA = rgb2hsb(colorA);


    hsvColorA.g = 1.0 - (amplitude * 1 * abs(cos(time * pi * 0.5)));
    
   


    color = hsb2rgb(hsvColorA);
    
    color = clamp(color * brightness, 0.0, 1.0);
    
   
    
    gl_FragColor =  vec4(color, alpha);
 
 }
 
