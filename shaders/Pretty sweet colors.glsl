// https://www.shadertoy.com/view/NlXBDn

#version 330 core

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

// CC0: Pretty sweet colors
//  I watched a YT (https://www.youtube.com/watch?v=pG0t19bEYJw), didn't remember anything except I thought 
//  the colors and shapes were pretty sweet around 0:09 in the video. So improvised a shader around it.
//  Unfortunately in chromium (Chrome, Edge etc) the colors for me looks dull and boring. Hopefully it's ok for you.
//  In FF it looks right though.

#define RESOLUTION  resolution
#define TIME        time / 1000.
#define PI          3.141592654
#define TAU         (2.0*PI)
#define ROT(a)      mat2(cos(a), sin(a), -sin(a), cos(a))

// License: WTFPL, author: sam hocevar, found: https://stackoverflow.com/a/17897228/418488
const vec4 hsv2rgb_K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
vec3 hsv2rgb(vec3 c) {
  vec3 p = abs(fract(c.xxx + hsv2rgb_K.xyz) * 6.0 - hsv2rgb_K.www);
  return c.z * mix(hsv2rgb_K.xxx, clamp(p - hsv2rgb_K.xxx, 0.0, 1.0), c.y);
}
// License: WTFPL, author: sam hocevar, found: https://stackoverflow.com/a/17897228/418488
//  Macro version of above to enable compile-time constants
#define HSV2RGB(c)  (c.z * mix(hsv2rgb_K.xxx, clamp(abs(fract(c.xxx + hsv2rgb_K.xyz) * 6.0 - hsv2rgb_K.www) - hsv2rgb_K.xxx, 0.0, 1.0), c.y))

// License: Unknown, author: nmz (twitter: @stormoid), found: https://www.shadertoy.com/view/NdfyRM
float sRGB(float t) { return mix(1.055*pow(t, 1./2.4) - 0.055, 12.92*t, step(t, 0.0031308)); }
// License: Unknown, author: nmz (twitter: @stormoid), found: https://www.shadertoy.com/view/NdfyRM
vec3 sRGB(in vec3 c) { return vec3 (sRGB(c.x), sRGB(c.y), sRGB(c.z)); }


float plane(vec2 p, vec3 pl) {
  return dot(p, pl.xy) + pl.z;
}

vec2 toSmith(vec2 p)  {
  // z = (p + 1)/(-p + 1)
  // (x,y) = ((1+x)*(1-x)-y*y,2y)/((1-x)*(1-x) + y*y)
  float d = (1.0 - p.x)*(1.0 - p.x) + p.y*p.y;
  float x = (1.0 + p.x)*(1.0 - p.x) - p.y*p.y;
  float y = 2.0*p.y;
  return vec2(x,y)/d;
}

vec2 fromSmith(vec2 p)  {
  // z = (p - 1)/(p + 1)
  // (x,y) = ((x+1)*(x-1)+y*y,2y)/((x+1)*(x+1) + y*y)
  float d = (p.x + 1.0)*(p.x + 1.0) + p.y*p.y;
  float x = (p.x + 1.0)*(p.x - 1.0) + p.y*p.y;
  float y = 2.0*p.y;
  return vec2(x,y)/d;
}

const vec3[] bcols = vec3[](
    HSV2RGB(vec3(243.0/360.0,0.95,0.07))
  , HSV2RGB(vec3(246.0/360.0,0.89,0.28))
  , HSV2RGB(vec3(244.0/360.0,0.80,0.23))
  , HSV2RGB(vec3(263.0/360.0,0.84,0.27))
  , HSV2RGB(vec3(277.0/360.0,0.86,0.26))
  , HSV2RGB(vec3(337.0/360.0,0.98,0.61))
  , HSV2RGB(vec3(348.0/360.0,0.99,0.83))
  , HSV2RGB(vec3(357.0/360.0,0.93,0.85))
  );
const int noOfBCols = bcols.length();

vec2 transform(vec2 p, float i) {
  float tm = TIME * 0.2;
  float ii = i/float(noOfBCols);
  float f =sin(3.0 * p.y + 2.1 * i + tm);
  vec2 sp = toSmith(p);
//  sp.y -= 0.1*i+0.9*sin(+0.1*i);
  sp *= ROT(0.1 * i + tm);
  sp *= ROT(mix(0.0, 0.2, ii) * f);
//  p.x += 0.08*f;
  p = fromSmith(sp);;
  return p;
}

float df(vec2 p, float i) {
  return plane(p, vec3(normalize(-vec2(1.0, 1.0)), 0.2 * i - 0.3));
}

vec3 effect(vec2 p, vec2 np) {
  float aaa = 2.0/RESOLUTION.y;
  vec3 col = bcols[0];
  
  for (int i = 1; i < noOfBCols; ++i) {
    float ii = float(i);
    vec2 pp   = transform(p, ii);
    vec2 npp  = transform(np, ii);
    float aa  = distance(pp, npp)*sqrt(0.5);
    float d = df(pp, ii);
    col = mix(col, col*0.33, exp(-max(10.0*d*aaa/aa, 0.0)));
    col = mix(col, bcols[i], smoothstep(aa, -aa, d));
  }
  
  
  return col;
}

void main() {
  vec2 q  = gl_FragCoord.xy / RESOLUTION.xy;
  // vec2 p  = -1.0 + 2.0 * q;
  vec2 p  = -1. + 2.5 * q;
  p.x    *= RESOLUTION.x / RESOLUTION.y;
  vec2 np = p + 2.0/RESOLUTION.y;
  
  vec3 col = effect(p, np);
  col = sRGB(col);
  outColor = vec4(col, 1.0);
}


