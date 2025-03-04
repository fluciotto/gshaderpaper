// https://www.shadertoy.com/view/7dsBRB

#version 330 core

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

//<300 chars playlist: https://www.shadertoy.com/playlist/fXlGDN

// Based on gaz's hypercube:
// https://www.shadertoy.com/view/NlcSDS

// Twigl: https://t.co/MCkEtXRfYM
// Tweet: https://twitter.com/XorDev/status/1493984559498768384

//FabriceNeyret2 saved 3 chars
//coyote save 9 chars

void main() {
    outColor -= outColor; //Clear color
    vec3 R = vec3(resolution, 1.), //Temporary resolution
         p = 4./R, //Camera position
         A = vec3(0,.6,.8), //Rotation axis
         q = R-R; //Rotated position

    for( float i=0.,s; i++<3e2; ) 
        q = int(i)% 3 > 1 ? //Step forward every 3 iterations
                s = length(--q.xz)*.5 - .04, //Step distance
                outColor += .9/exp(s*vec4(1,2,4,1))/i, //Color based on SDF
                abs( mix(A*dot(p -= normalize(vec3(gl_FragCoord.xy + gl_FragCoord.xy, R) - R) * s,A), //Step forward
                         p, cos(s=time / 1000.))+sin(s)*cross(p,A) ) //Rotate cube
            :    
                q.x<q.y ? q.zxy : q.zyx; //gaz's clever axis sorting trick
        
    outColor *= outColor;
}

//Original in 299 chars:
/*
void mainImage(out vec4 O, vec2 C)
{
    O-=O; 
    
    vec3 r = iResolution, 
    d = normalize(vec3(C+C-r.xy,r)),
    q, p; //Initialize vectors
    r = vec3(0,.6,.8); //Rotation axis
    p.z -= 4.; //Move backward
    
    for(float i=0.,s,t=iTime; i++<3e2;)
        
        int(i)%3>1? //Step forward every 3 iterations
            s = length(--q.xz)*.5-.04, //Step distance
            p += d*s, //Step forward in ray direction
            O += .9/exp(s*vec4(1,2,4,1))/i, //Color based on SDF
            q = abs(mix(r*dot(p,r),p,cos(t))+sin(t)*cross(p,r)) //Rotate cube
            :
            //gaz's clever axis sorting trick
            q = q.x<q.y?q.zxy:q.zyx;
        
    O *= O;
}*/