#version 330 core
uniform float time;
uniform vec2 resolution;

void main() {
  vec2 r = resolution;
  float t = time / 1000.;
  vec2 p = (gl_FragCoord.xy - .5 * r) / r.y;

  float l = sin(fract(length(p)));
  
  gl_FragColor = vec4(l, 0., 0., 1.);
}