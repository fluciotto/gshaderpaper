// https://www.shadertoy.com/view/cltfRf

#version 330 core

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

/*
    "Shield" by @XorDev
    
    Inspired by @cmzw's work: witter.com/cmzw_/status/1729148918225916406
    
    X: X.com/XorDev/status/1730436700000649470
    Twigl: twigl.app/?ol=true&ss=-NkYXGfK5wEl4VaUQ9zS
*/
void main()
{
    //Iterator, z and time
    float i,z,t = time / 1000.;
    //Clear frag and loop 100 times
    for(outColor *= i; i < 1.; i += .01)
    {
        //Resolution for scaling
        vec2 v = resolution.xy / 1.2,
        //Center and scale outward
        p=(gl_FragCoord.xy + gl_FragCoord.xy - v) / v.y * i;
        //Sphere distortion and compute z
        p/=.2+sqrt(z=max(1.-dot(p,p),0.))*.3;
        //Offset for hex pattern
        p.y+=fract(ceil(p.x=p.x/.9+t)*.5)+t*.2;
        //Mirror quadrants
        v=abs(fract(p)-.5);
        //Add color and fade outward
        outColor += vec4(2,3,5,1)/2e3*z/
        //Compute hex distance
        (abs(max(v.x*1.5+v,v+v).y-1.)+.1-i*.09);
    }
    //Tanh tonemap
    outColor = tanh(outColor * outColor);
}