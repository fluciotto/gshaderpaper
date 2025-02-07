#version 410
// #version 300 es
// precision highp float; 

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

vec4 map_to_color(float t) {
  float r = 9.0 * (1.0 - t) * t * t * t;
  float g = 15.0 * (1.0 - t) * (1.0 - t) * t * t;
  float b = 8.5 * (1.0 - t) * (1.0 - t) * (1.0 - t) * t;
  return vec4(r, g, b, 1.0);
}

void main() {
  vec2 r = resolution;
  float t = time / 1000.;
  vec2 p = (gl_FragCoord.xy - .5 * r) / r.y;

  // int itr = int(10. * cos(t));
  // int itr = int(1000. * cos(t) * cos(t) + 10.);
  int itr = 20;
  // float zoom = 1. * exp(t);
  float zoom = .4;

  dvec2 z, c = p / zoom; // + vec2(.25, 0);

  int i;
  for(i = 0; i < itr; i++) {
    double x = (z.x * z.x - z.y * z.y) + c.x;
    double y = (z.y * z.x + z.x * z.y) + c.y;

    // if((x * x + y * y) > 2.0) break;
    if((x * x + y * y) > pow(sin(t/10.), 2.) * 2. + .6) break;
    z.x = x;
    z.y = y;
  }

  double t2 = double(i) / double(itr);

  outColor = map_to_color(float(t2));
}