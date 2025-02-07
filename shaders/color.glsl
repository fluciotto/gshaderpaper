#version 330 core
uniform float time;
uniform vec2 resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / resolution;
  gl_FragColor = vec4(uv.x, uv.y, sin(time / 1000.), 1.0);
}