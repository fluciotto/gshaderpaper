// https://x.com/natchinoyuchi/status/1645041598349328387

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

  for(float F, L, O, W; F++ < 96.; outColor += .02 / exp(3e2 * L * gl_FragCoord.ptqs)) {
    vec3 E, R = vec3((gl_FragCoord.rg / r - .5) * W, W - 6.) * rotate3D(t, ++E);
    O = 2.;
    R.g *= .7;
    R *= L = 9. / dot(R, R);
    O *= L;
    R.sp *= rotate2D(R.t * .5 + t / F);
    for(int E; E++ < 6; R.xz *= rotate2D(.5))
      R.p = abs(R.b);
    W += L = abs(cos(R.t + t * 9.)) * sin(R.s * R.b / 1e2) * 6. / O + .5 / O;
  }
}