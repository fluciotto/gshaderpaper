// https://x.com/zozuar/status/1621229990267310081

#version 330 core
uniform float time;
uniform vec2 resolution;

mat2 rotate2d(float a) {
	float c = cos(a), s = sin(a);
  return mat2(c, s, -s, c);
}

void main() {
  vec2 r = resolution;
  float t = time / 1000.0;
  vec2 n, q;
  vec2 p = (gl_FragCoord.xy - .5 * r) / r.y;
  float d = dot(p, p);
  float S = 9.;
  float i, a, j;
  for(mat2 m = rotate2d(5.); j++<30.; ) {
    p *= m;
    n *= m;
    q = p * S + t * 4. + sin(t * 4. - d * 6.) * .8 + j + n;
    a += dot(cos(q) / S, vec2(.2));
    n -= sin(q);
    S *= 1.2;
  }
  gl_FragColor += (a + .2) * vec4(4, 2, 1, 0) + a + a - d;
}