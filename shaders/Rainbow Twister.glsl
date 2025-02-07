// https://www.shadertoy.com/view/XsSfW1

#version 330 core

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

float iTime = time / 1000.;

//With AA (239 c)

void main() {
    vec2 r = resolution.xy;
    vec2 o = gl_FragCoord.xy;
    o = vec2(length(o -= r / 2.) / r.y - .3, atan(o.y, o.x));
    vec4 s = outColor.yzwx = .1 * cos(1.6 * vec4(0, 1, 2, 3) + iTime + o.y + sin(o.y) * sin(iTime) * 2.),
    f = min(o.x - s, outColor - o.x);
    outColor = dot(40. * (s - outColor), clamp(f * r.y, 0., 1.)) * (s - .1) - f;
}


//No AA (233c)
/*
void mainImage( out vec4 c, vec2 o )
{
    vec2 r = iResolution.xy;
    o = vec2(length(o -= r/2.) / r.y - .3, atan(o.y,o.x));    
    vec4 s = c.yzwx = .1*cos(1.6*vec4(0,1,2,3) + iTime + o.y + sin(o.y) * sin(iTime)*2.);
    c = dot(40.*(s-c), step(1./r.y, c = min(o.x-s,c-o.x))) * (s-.1) - c;
}
*/
