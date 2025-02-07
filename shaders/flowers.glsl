// https://x.com/zozuar/status/1763906851337326736

#version 330 core
// #version 300 es
// precision highp float; 

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

mat2 rotate2D(float a) {
	float c = cos(a), s = sin(a);
  return mat2(c, s, -s, c);
}

//
// Simplex 2D noise
//

// float snoise2D(vec2 c) {
//   return fract(sin(dot(c, vec2(12.9898, 78.233))) * 43758.5453);
// }

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise2D(vec2 v){
  const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

void main() {
  vec2 r = resolution;
  float t = time / 1000.;

  vec3 p, q = vec3(-.1, .65, -.6);
  for(
    float j, i, e, v, u;
    i++ < 130.;
    outColor += .007 / exp(3e3 / (v * vec4(9, 5, 4, 4) + e * 4e6))
  ) {
    p = q += vec3((gl_FragCoord.xy - .5 * r) / r.y, 1) * e;
    for(j = e = v = 7.; j++ <21. ;e = min(e, max(length(p.xz = abs(p.xz * rotate2D(j + sin(1. / u + t) / v)) - .53) - .02 / u, p.y = 1.8 - p.y) / v)) {
      v /= u = dot(p, p), p /= u + .01;
    }
  }
}