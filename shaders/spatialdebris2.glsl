#version 330 core
// #version 300 es
// precision highp float; 

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

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

  vec2 p = (gl_FragCoord.xy - r * .5) / r.y * mat2(8, -6, 6, 8), v;
  for(
    float i, f = 3. + snoise2D(p + vec2(t * 7., 0));
    i++ < 50.;
    outColor += (cos(sin(i) * vec4(1, 2, 3, 1)) + 1.) * exp(sin(i * i + t)) / length(max(v, vec2(v.x * f * .02, v.y)))
  ) {
    v = p + cos(i * i + (t + p.x * .1) * .03 + i * vec2(11, 9)) * 5.;
  }
  outColor = tanh(pow(outColor / 1e2, vec4(1.5)));
}