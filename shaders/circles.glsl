// https://x.com/YoheiNishitsuji/status/1875032960547819698

#version 330 core
// #version 300 es
// precision highp float; 

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

vec3 hsv(float h, float s, float v) {
  vec4 t = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(vec3(h) + t.xyz) * 6.0 - vec3(t.w));
  return v * mix(vec3(t.x), clamp(p - vec3(t.x), 0.0, 1.0), s);
}

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

void main() {
  vec2 r = resolution;
  float t = time / 1000.;
  float i, g, e, s;

  for(; ++i < 13.; ) {
    vec3 p = vec3((gl_FragCoord.xy - .5 * r) / r.y * (6. + cos(t * .5) * 2.), g + .6) * rotate3D(t * .5, vec3(1));
    s = 1.;
    for(int i; i++ < 55; p = vec3(0., 3.01, 3.) - abs(abs(p) * e - vec3(2.2, 3., 3.))) {
        s *= e = max(1., 10.5 / dot(p, p));
    }
    g -= mod(length(p.yy), p.y) / s * .4;
    outColor.rgb += hsv(.02 / g + .2, p.x, s / 5e3);
    // outColor.a = 1.;
  }
}