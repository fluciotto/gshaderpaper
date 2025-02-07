// https://www.shadertoy.com/view/tltXDN

#version 330 core

uniform float time;
uniform vec2 resolution;
out vec4 outColor;

float iTime = time / 1000.;
vec2 iMouse = vec2(0., 0.);

// Created by David Gallardo - xjorma/2020
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0


#if HW_PERFORMANCE==0
#else
#define AA
#endif


const float	layerThickness	= 0.02;
const int	nbLayers 		= 7;


float sdTorus( vec3 p, vec2 t )
{
    return length( vec2(length(p.xz)-t.x,p.y) )-t.y;
}


float saturate(float c)
{
    return clamp(c,0.,1.);
}


vec2 minVecSelect(vec2 a, vec2 b)
{
    return a.x<b.x?a:b;
}

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

vec2 map(in vec3 p)
{
    float slide = iTime / 1.;
    float fr = fract(slide);
    int   fl = int(floor(slide));    
    vec2  vd = vec2(100., -1.);
    float cnoise = noise(p * 2. + iTime / 8.) / 3.;
    float o = 100.0f;
    for( int i = 0; i < nbLayers; i++)
    {
        float m = mod(float(i + fl), float(nbLayers));
        float r = 0.6 - m * layerThickness + ( 1. - fr) * layerThickness;
        float d = sdTorus( p, vec2(1, r)) ;
        d = d - layerThickness / 2.;
        float o =  - 4. * fract( (iTime + float(i)) / float(nbLayers));
        float n = 1.5 + p.x  + o + cnoise;
		d = max(d, n);
 		vd = minVecSelect(vec2(d, float(i)), vd);        
    }   
    return vd;
}


vec3 calcNormal(vec3 p)
{
    const float h = 0.001;
    const vec2 k = vec2(1,-1);
    return normalize( k.xyy * map(p + k.xyy*h).x + 
                      k.yyx * map(p + k.yyx*h).x + 
                      k.yxy * map(p + k.yxy*h).x + 
                      k.xxx * map(p + k.xxx*h).x );
}

// From IQ
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/12.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return saturate(1.0 - 4. * occ);    
}


vec3 Render(vec3 ro,vec3 rd,vec3 cd,float dist)
{
    float t = 0.5;
    float d;
    float m = 0.;
    for( int i=0; i<1024; i++ )
    {
        vec3	p = ro + t*rd;
        vec2	h = map(p);
        t += h.x*0.7;
        d = dot(t*rd,cd);
        m = h.y;
        if( abs(h.x)<0.0001 || d>dist ) break;
    }

    vec3 col = vec3(0.3);

    if( d<dist )
    {
        vec3 light = vec3(0.,4.,2.);
        vec3 p = ro + t*rd;
        vec3 n = calcNormal(p);
        vec3 v = normalize(ro-p);
        vec3 l = normalize(light-p);
        vec3 h = normalize(l+v);
        
        vec3 diffcol = normalize(vec3(1. + sin(m * 0.7 + 1.3) / 2., 1. + sin(m * 1.3 + 4.45) / 2., 1. + sin(m * 1.9 + 2.3) / 2.)); 
        vec3 speccol = vec3(1.,1.,1.);
        vec3 ambcol = diffcol;
		float ao = calcAO(p, n);
        
        col = saturate(dot(n,l)) * diffcol;
        col+= pow(saturate(dot(n,h)),40.) * speccol * 0.5;
        col+= 0.2 * ambcol;
        col*= ao;
    }
    return col;
}

void mainVR( out vec4 fragColor, in vec2 gl_FragCoord, in vec3 ro, in vec3 rd )
{
    fragColor = vec4(Render(ro/3. + vec3(0.0,.0,4.0),rd ,rd,14.) ,1);
}

mat3 setCamera( in vec3 ro, in vec3 ta )
{
	vec3 cw = normalize(ta-ro);
	vec3 up = vec3(0, 1, 0);
	vec3 cu = normalize( cross(cw,up) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

vec3 vignette(vec3 color, vec2 q, float v)
{
    color *= 0.3 + 0.8 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), v);
    return color;
}

vec3 desaturate(in vec3 c, in float a)
{
    float l = dot(c, vec3(1. / 3.));
    return mix(c, vec3(l), a);
}

void main()
{
	vec3 tot = vec3(0.0);
        
#ifdef AA
	vec2 rook[4];
    rook[0] = vec2( 1./8., 3./8.);
    rook[1] = vec2( 3./8.,-1./8.);
    rook[2] = vec2(-1./8.,-3./8.);
    rook[3] = vec2(-3./8., 1./8.);
    for( int n=0; n<4; ++n )
    {
        // pixel coordinates
        vec2 o = rook[n];
        vec2 p = (-resolution.xy + 2.0*(gl_FragCoord.xy+o))/resolution.y;
#else //AA
        vec2 p = (-resolution.xy + 2.0*gl_FragCoord.xy)/resolution.y;
#endif //AA
 
        // camera
        
        float theta	= radians(360.)*(iMouse.x/resolution.x-0.5) + iTime*.1;
        float phi	= radians(45.) + radians(90.)*(iMouse.y/resolution.y-0.5)-1.;
        vec3 ro = 2.7*vec3( sin(phi)*cos(theta),cos(phi),sin(phi)*sin(theta));
        //vec3 ro = vec3(0.0,.2,4.0);
        vec3 ta = vec3(0, -0.2, 0);
        // camera-to-world transformation
        mat3 ca = setCamera( ro, ta );
        //vec3 cd = ca[2];    
        
        vec3 rd =  ca*normalize(vec3(p,1.5));        
        
        vec3 col = Render(ro ,rd ,ca[2],20.);

	    tot += col;
#ifdef AA
    }
    tot /= 4.;
#endif
    
    tot = desaturate(tot, -0.4);
    tot = vignette(tot, gl_FragCoord.xy / resolution.xy, 0.8);
    tot = pow(tot, vec3(1./2.2));

	outColor = vec4( tot, 1.0 );
}