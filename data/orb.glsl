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
uniform float time;



vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void main()
{
    vec2 st = gl_FragCoord.xy/resolution.xy;
    st.x *= resolution.x/resolution.y;
    vec3 color = vec3(0.0);

    vec2 mouse = mousePos.xy / resolution.xy;
    mouse = vec2(mouse.x, 1.0 - mouse.y);
    mouse.x *= resolution.x / resolution.y;
    float size = 0.05;

    float margin_left = mouse.x - size ;
    float margin_right = 1.0 - (mouse.x - size);
    float margin_top = 0.01;
    float margin_bottom = 0.01;

    if(st.x >= margin_left && st.x <= 1.0 - margin_right)
    {
        if (st.y <= margin_top && st.y >= 1.0 - margin_bottom)
        {
            // Scale
            st *= 40.;

            // Tile the space
            vec2 i_st = floor(st);
            vec2 f_st = fract(st);

            float m_dist = 1.0;  // minimun distance

            for (int y= -1; y <= 1; y++) {
                for (int x= -1; x <= 1; x++) {
                    // Neighbor place in the grid
                    vec2 neighbor = vec2(float(x),float(y));

                    // Random position from current + neighbor place in the grid
                    vec2 point = random2(i_st + neighbor);

                    // Animate the point
                    point = 0.5 + 0.5*sin((time * 2.) + 6.2831*point);

                    // Vector between the pixel and the point
                    vec2 diff = neighbor + point - f_st;

                    // Distance to the point
                    float dist = length(diff);

                    // Keep the closer distance
                    m_dist = min(m_dist, dist);
                }
            }

            // Draw the min distance (distance field)
            color += m_dist;
        }   
    }

    

    gl_FragColor = vec4(color,1.0);
}