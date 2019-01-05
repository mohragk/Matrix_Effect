#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
 
#define PROCESSING_TEXTURE_SHADER
 
uniform sampler2D texture;
//uniform sampler2D foregroundTex;

// The inverse of the texture dimensions along X and Y
uniform vec2 texOffset;
 
varying vec4 vertColor;
varying vec4 vertTexCoord;
 
 
 void main()
 {
 
    vec4 bgColor = texture2D( texture, vertTexCoord.st);
    //vec4 fgColor = texture2D ( foregroundTex, vertTexCoord.st);
 
 
    //vec4 color = fgColor < 0.5 ? (2.0 * fgColor * bgColor) : ( 1.0 - 2.0 * ( 1 - fgColor ) * ( 1.0 - bgColor ));
    
    float colR = bgColor.r;
    
    vec3 color;
    color.r = colR;
    color.g = 0.0;
    color.b = 0.1;
    
    //a < .5 ? (2 * a * b) : (1 - 2 * (1 - a) * (1 - b))
    
    gl_FragColor = vec4(color.rgb, 1.0);
 
 }