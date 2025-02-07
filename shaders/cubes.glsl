// https://x.com/zozuar/status/1631115224827691009

#version 330 core
// #version 300 es
// precision highp float; 

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

mat3 rotate3D(float angle, vec3 axis){
  vec3 a = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float r = 1.0 - c;
  return mat3(
    a.x * a.x * r + c,
    a.y * a.x * r + a.z * s,
    a.z * a.x * r - a.y * s,
    a.x * a.y * r - a.z * s,
    a.y * a.y * r + c,
    a.z * a.y * r + a.x * s,
    a.x * a.z * r + a.y * s,
    a.y * a.z * r - a.x * s,
    a.z * a.z * r + c
  );
}

vec3 hsv(float h, float s, float v) {
  vec4 t = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(vec3(h) + t.xyz) * 6.0 - vec3(t.w));
  return v * mix(vec3(t.x), clamp(p - vec3(t.x), 0.0, 1.0), s);
}


void main() {
  vec2 r = resolution;
  float t = time / 1000.;

  vec3 p, q, d;
  d.zx = (gl_FragCoord.xy - .5 * r) / r.y;
  d.y--;
  d *= rotate3D(.5, hsv(t / 6., 9., p.y += .3));
  for(
    float i, j, e, S;
    i++ < 1e2;
    i > 70. ? e += 2e-4, d /= d, outColor : outColor += .01 / exp(e * 1e4), p += d * e * .5) {
    for(j = e = p.y; j++ < 9.; e = min(e, length(q - clamp(q, -.2, .2)) / S)) {
      q = p * (S = exp2(j - fract(t))), q.xz = fract(q.xz) - .5;
    }
  }
  outColor += log(p.y) * .1;
}