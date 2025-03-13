#define GLSLIFY 1
// all sdfs
float sdPlane(vec3 p,vec3 n,float h)
{
    // n must be normalized
    return dot(p,n)+h;
}

float sdSphere(vec3 p,float s)
{
    return length(p)-s;
}

float sdBox(vec3 p,vec3 b)
{
    vec3 q=abs(p)-b;
    return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.);
}

float sdBoxFrame(vec3 p,vec3 b,float e)
{
    p=abs(p)-b;
    vec3 q=abs(p+e)-e;
    return min(min(
            length(max(vec3(p.x,q.y,q.z),0.))+min(max(p.x,max(q.y,q.z)),0.),
            length(max(vec3(q.x,p.y,q.z),0.))+min(max(q.x,max(p.y,q.z)),0.)),
            length(max(vec3(q.x,q.y,p.z),0.))+min(max(q.x,max(q.y,p.z)),0.));
        }
        
        
float sdEllipsoid(vec3 p,vec3 r)
{
    float k0=length(p/r);
    float k1=length(p/(r*r));
    return k0*(k0-1.)/k1;
}

float sdTorus(vec3 p,vec2 t)
{
    vec2 q=vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

float sdCappedTorus(in vec3 p,in vec2 sc,in float ra,in float rb)
{
    p.x=abs(p.x);
    float k=(sc.y*p.x>sc.x*p.y)?dot(p.xy,sc):length(p.xy);
    return sqrt(dot(p,p)+ra*ra-2.*ra*k)-rb;
}

float sdHexPrism(vec3 p,vec2 h)
{
    const vec3 k=vec3(-.8660254,.5,.57735);
    p=abs(p);
    p.xy-=2.*min(dot(k.xy,p.xy),0.)*k.xy;
    vec2 d=vec2(
        length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x),h.x))*sign(p.y-h.x),
    p.z-h.y);
    return min(max(d.x,d.y),0.)+length(max(d,0.));
}

float sdOctogonPrism(in vec3 p,in float r,float h)
{
    const vec3 k=vec3(-.9238795325,// sqrt(2+sqrt(2))/2
    .3826834323,// sqrt(2-sqrt(2))/2
.4142135623);// sqrt(2)-1
// reflections
p=abs(p);
p.xy-=2.*min(dot(vec2(k.x,k.y),p.xy),0.)*vec2(k.x,k.y);
p.xy-=2.*min(dot(vec2(-k.x,k.y),p.xy),0.)*vec2(-k.x,k.y);
// polygon side
p.xy-=vec2(clamp(p.x,-k.z*r,k.z*r),r);
vec2 d=vec2(length(p.xy)*sign(p.y),p.z-h);
return min(max(d.x,d.y),0.)+length(max(d,0.));
}

float sdCapsule(vec3 p,vec3 a,vec3 b,float r)
{
    vec3 pa=p-a,ba=b-a;
    float h=clamp(dot(pa,ba)/dot(ba,ba),0.,1.);
    return length(pa-ba*h)-r;
}

float dot2_0(in vec2 v){return dot(v,v);}
float dot2_0(in vec3 v){return dot(v,v);}

float sdRoundCone(vec3 p,float r1,float r2,float h)
{
    // sampling independent computations (only depend on shape)
    float b=(r1-r2)/h;
    float a=sqrt(1.-b*b);
    
    // sampling dependant computations
    vec2 q=vec2(length(p.xz),p.y);
    float k=dot(q,vec2(-b,a));
    if(k<0.)return length(q)-r1;
    if(k>a*h)return length(q-vec2(0.,h))-r2;
    return dot(q,vec2(a,b))-r1;
}

float sdRoundCone(vec3 p,vec3 a,vec3 b,float r1,float r2)
{
    // sampling independent computations (only depend on shape)
    vec3 ba=b-a;
    float l2=dot(ba,ba);
    float rr=r1-r2;
    float a2=l2-rr*rr;
    float il2=1./l2;
    
    // sampling dependant computations
    vec3 pa=p-a;
    float y=dot(pa,ba);
    float z=y-l2;
    float x2=dot2_0(pa*l2-ba*y);
    float y2=y*y*l2;
    float z2=z*z*l2;
    
    // single square root!
    float k=sign(rr)*rr*rr*x2;
    if(sign(z)*a2*z2>k)return sqrt(x2+z2)*il2-r2;
    if(sign(y)*a2*y2<k)return sqrt(x2+y2)*il2-r1;
    return(sqrt(x2*a2*il2)+y*rr)*il2-r1;
}

float sdTriPrism(vec3 p,vec2 h)
{
    vec3 q=abs(p);
    return max(q.z-h.y,max(q.x*.866025+p.y*.5,-p.y)-h.x*.5);
}

// infinite
float sdCylinder(vec3 p,vec3 c)
{
    return length(p.xz-c.xy)-c.z;
}

// vertical
float sdCylinder(vec3 p,vec2 h)
{
    vec2 d=abs(vec2(length(p.xz),p.y))-h;
    return min(max(d.x,d.y),0.)+length(max(d,0.));
}

// arbitrary orientation
float sdCylinder(vec3 p,vec3 a,vec3 b,float r)
{
    vec3 pa=p-a;
    vec3 ba=b-a;
    float baba=dot(ba,ba);
    float paba=dot(pa,ba);
    
    float x=length(pa*baba-ba*paba)-r*baba;
    float y=abs(paba-baba*.5)-baba*.5;
    float x2=x*x;
    float y2=y*y*baba;
    float d=(max(x,y)<0.)?-min(x2,y2):(((x>0.)?x2:0.)+((y>0.)?y2:0.));
    return sign(d)*sqrt(abs(d))/baba;
}

float sdCone(in vec3 p,in vec2 c,float h)
{
    // c is the sin/cos of the angle, h is height
    // Alternatively pass q instead of (c,h),
    // which is the point at the base in 2D
    vec2 q=h*vec2(c.x/c.y,-1.);
    
    vec2 w=vec2(length(p.xz),p.y);
    vec2 a=w-q*clamp(dot(w,q)/dot(q,q),0.,1.);
    vec2 b=w-q*vec2(clamp(w.x/q.x,0.,1.),1.);
    float k=sign(q.y);
    float d=min(dot(a,a),dot(b,b));
    float s=max(k*(w.x*q.y-w.y*q.x),k*(w.y-q.y));
    return sqrt(d)*sign(s);
}

float dot2_1(in vec2 v){return dot(v,v);}
float dot2_1(in vec3 v){return dot(v,v);}

float sdCappedCone(vec3 p,float h,float r1,float r2)
{
    vec2 q=vec2(length(p.xz),p.y);
    vec2 k1=vec2(r2,h);
    vec2 k2=vec2(r2-r1,2.*h);
    vec2 ca=vec2(q.x-min(q.x,(q.y<0.)?r1:r2),abs(q.y)-h);
    vec2 cb=q-k1+k2*clamp(dot(k1-q,k2)/dot2_1(k2),0.,1.);
    float s=(cb.x<0.&&ca.y<0.)?-1.:1.;
    return s*sqrt(min(dot2_1(ca),dot2_1(cb)));
}

float sdCappedCone(vec3 p,vec3 a,vec3 b,float ra,float rb)
{
    float rba=rb-ra;
    float baba=dot(b-a,b-a);
    float papa=dot(p-a,p-a);
    float paba=dot(p-a,b-a)/baba;
    float x=sqrt(papa-paba*paba*baba);
    float cax=max(0.,x-((paba<.5)?ra:rb));
    float cay=abs(paba-.5)-.5;
    float k=rba*rba+baba;
    float f=clamp((rba*(x-ra)+paba*baba)/k,0.,1.);
    float cbx=x-ra-f*rba;
    float cby=paba-f;
    float s=(cbx<0.&&cay<0.)?-1.:1.;
    return s*sqrt(min(cax*cax+cay*cay*baba,
        cbx*cbx+cby*cby*baba));
    }
    
    
float sdSolidAngle(vec3 p,vec2 c,float ra)
{
    // c is the sin/cos of the angle
    vec2 q=vec2(length(p.xz),p.y);
    float l=length(q)-ra;
    float m=length(q-c*clamp(dot(q,c),0.,ra));
    return max(l,m*sign(c.y*q.x-c.x*q.y));
}

float sdOctahedron(vec3 p,float s)
{
    p=abs(p);
    float m=p.x+p.y+p.z-s;
    vec3 q;
    if(3.*p.x<m)q=p.xyz;
    else if(3.*p.y<m)q=p.yzx;
    else if(3.*p.z<m)q=p.zxy;
    else return m*.57735027;
    
    float k=clamp(.5*(q.z-q.y+s),0.,s);
    return length(vec3(q.x,q.y-s+k,q.z-k));
}

float sdPyramid(vec3 p,float h)
{
    float m2=h*h+.25;
    
    p.xz=abs(p.xz);
    p.xz=(p.z>p.x)?p.zx:p.xz;
    p.xz-=.5;
    
    vec3 q=vec3(p.z,h*p.y-.5*p.x,h*p.x+.5*p.y);
    
    float s=max(-q.x,0.);
    float t=clamp((q.y-.5*p.z)/(m2+.25),0.,1.);
    
    float a=m2*(q.x+s)*(q.x+s)+q.y*q.y;
    float b=m2*(q.x+.5*t)*(q.x+.5*t)+(q.y-m2*t)*(q.y-m2*t);
    
    float d2=min(q.y,-q.x*m2-q.y*.5)>0.?0.:min(a,b);
    
    return sqrt((d2+q.z*q.z)/m2)*sign(max(q.z,-p.y));
}

float ndot(in vec2 a,in vec2 b){return a.x*b.x-a.y*b.y;}

float sdRhombus(vec3 p,float la,float lb,float h,float ra)
{
    p=abs(p);
    vec2 b=vec2(la,lb);
    float f=clamp((ndot(b,b-2.*p.xz))/dot(b,b),-1.,1.);
    vec2 q=vec2(length(p.xz-.5*b*vec2(1.-f,1.+f))*sign(p.x*b.y+p.z*b.x-b.x*b.y)-ra,p.y-h);
    return min(max(q.x,q.y),0.)+length(max(q,0.));
}

// http://iquilezles.org/www/articles/boxfunctions/boxfunctions.htm
vec2 iBox(in vec3 ro,in vec3 rd,in vec3 rad)
{
    vec3 m=1./rd;
    vec3 n=m*ro;
    vec3 k=abs(m)*rad;
    vec3 t1=-n-k;
    vec3 t2=-n+k;
    return vec2(max(max(t1.x,t1.y),t1.z),
    min(min(t2.x,t2.y),t2.z));
}

// sdf ops
float opUnion(float d1,float d2)
{
    return min(d1,d2);
}

vec2 opUnion(vec2 d1,vec2 d2)
{
    return(d1.x<d2.x)?d1:d2;
}

// ray
vec2 normalizeScreenCoords(vec2 screenCoord,vec2 resolution)
{
    vec2 result=2.*(screenCoord/resolution.xy-.5);
    result.x*=resolution.x/resolution.y;// Correct for aspect ratio
    return result;
}

mat3 setCamera(in vec3 ro,in vec3 ta,float cr)
{
    vec3 cw=normalize(ta-ro);
    vec3 cp=vec3(sin(cr),cos(cr),0.);
    vec3 cu=normalize(cross(cw,cp));
    vec3 cv=(cross(cu,cw));
    return mat3(cu,cv,cw);
}

vec3 getRayDirection(vec2 p,vec3 ro,vec3 ta,float fl){
    mat3 ca=setCamera(ro,ta,0.);
    vec3 rd=ca*normalize(vec3(p,fl));
    return rd;
}

// gamma
const float gamma=2.2;

float toGamma(float v){
    return pow(v,1./gamma);
}

vec2 toGamma(vec2 v){
    return pow(v,vec2(1./gamma));
}

vec3 toGamma(vec3 v){
    return pow(v,vec3(1./gamma));
}

vec4 toGamma(vec4 v){
    return vec4(toGamma(v.rgb),v.a);
}

// material
// http://iquilezles.org/www/articles/checkerfiltering/checkerfiltering.htm
float checkersGradBox(vec2 p)
{
    vec2 w=fwidth(p)+.001;
    vec2 i=2.*(abs(fract((p-.5*w)*.5)-.5)-abs(fract((p+.5*w)*.5)-.5))/w;
    return clamp(.5-.5*i.x*i.y,0.,1.);
}

vec3 blendNormal(vec3 normal){
    vec3 blending=abs(normal);
    blending=normalize(max(blending,.00001));
    blending/=vec3(blending.x+blending.y+blending.z);
    return blending;
}

// https://gamedevelopment.tutsplus.com/articles/use-tri-planar-texture-mapping-for-better-terrain--gamedev-13821
vec3 triplanarMapping(sampler2D tex,vec3 normal,vec3 position){
    vec3 normalBlend=blendNormal(normal);
    vec3 xColor=texture(tex,position.yz).rgb;
    vec3 yColor=texture(tex,position.xz).rgb;
    vec3 zColor=texture(tex,position.xy).rgb;
    return(xColor*normalBlend.x+yColor*normalBlend.y+zColor*normalBlend.z);
}

// lighting
// https://learnopengl.com/Lighting/Basic-Lighting

float saturate_1(float a){
    return clamp(a,0.,1.);
}

// https://learnopengl.com/Lighting/Basic-Lighting

float saturate_2(float a){
    return clamp(a,0.,1.);
}

float diffuse(vec3 n,vec3 l){
    float diff=saturate_2(dot(n,l));
    return diff;
}

// https://learnopengl.com/Lighting/Basic-Lighting

float saturate_0(float a){
    return clamp(a,0.,1.);
}

float specular(vec3 n,vec3 l,float shininess){
    float spec=pow(saturate_0(dot(n,l)),shininess);
    return spec;
}

// https://www.shadertoy.com/view/4scSW4
float fresnel(float bias,float scale,float power,vec3 I,vec3 N)
{
    return bias+scale*pow(1.+dot(I,N),power);
}

// fog
float fogFactorExp(
    const float dist,
    const float density
){
    return 1.-clamp(exp(-density*dist),0.,1.);
}

vec2 map(in vec3 pos){
    vec2 res=vec2(1e10,0.);
    
    res=opUnion(res,vec2(sdSphere(pos-vec3(-2.,.25,0.),.25),26.9));
    
    res=opUnion(res,vec2(sdBoxFrame(pos-vec3(0.,.25,0.),vec3(.3,.25,.2),.025),16.9));
    res=opUnion(res,vec2(sdTorus((pos-vec3(0.,.30,1.)).xzy,vec2(.25,.05)),25.));
    res=opUnion(res,vec2(sdCone(pos-vec3(0.,.45,-1.),vec2(.6,.8),.45),55.));
    res=opUnion(res,vec2(sdCappedCone(pos-vec3(0.,.25,-2.),.25,.25,.1),13.67));
    res=opUnion(res,vec2(sdSolidAngle(pos-vec3(0.,0.,-3.),vec2(3,4)/5.,.4),49.13));
    
    res=opUnion(res,vec2(sdCappedTorus((pos-vec3(1.,.30,1.))*vec3(1,-1,1),vec2(.866025,-.5),.25,.05),8.5));
    res=opUnion(res,vec2(sdBox(pos-vec3(1.,.25,0.),vec3(.3,.25,.1)),3.));
    res=opUnion(res,vec2(sdCapsule(pos-vec3(1.,0.,-1.),vec3(-.1,.1,-.1),vec3(.2,.4,.2),.1),31.9));
    res=opUnion(res,vec2(sdCylinder(pos-vec3(1.,.25,-2.),vec2(.15,.25)),8.));
    res=opUnion(res,vec2(sdHexPrism(pos-vec3(1.,.2,-3.),vec2(.2,.05)),18.4));
    
    res=opUnion(res,vec2(sdPyramid(pos-vec3(-1.,-.6,-3.),1.),13.56));
    res=opUnion(res,vec2(sdOctahedron(pos-vec3(-1.,.15,-2.),.35),23.56));
    res=opUnion(res,vec2(sdTriPrism(pos-vec3(-1.,.15,-1.),vec2(.3,.05)),43.5));
    res=opUnion(res,vec2(sdEllipsoid(pos-vec3(-1.,.25,0.),vec3(.2,.25,.05)),43.17));
    res=opUnion(res,vec2(sdRhombus((pos-vec3(-1.,.34,1.)).xzy,.15,.25,.04,.08),17.));
    
    res=opUnion(res,vec2(sdOctogonPrism(pos-vec3(2.,.2,-3.),.2,.05),51.8));
    res=opUnion(res,vec2(sdCylinder(pos-vec3(2.,.15,-2.),vec3(.1,-.1,0.),vec3(-.2,.35,.1),.08),31.2));
    res=opUnion(res,vec2(sdCappedCone(pos-vec3(2.,.10,-1.),vec3(.1,0.,0.),vec3(-.2,.40,.1),.15,.05),46.1));
    res=opUnion(res,vec2(sdRoundCone(pos-vec3(2.,.15,0.),vec3(.1,0.,0.),vec3(-.1,.35,.1),.15,.05),51.7));
    res=opUnion(res,vec2(sdRoundCone(pos-vec3(2.,.20,1.),.2,.1,.3),37.));
    
    return res;
}

vec2 raycast(in vec3 ro,in vec3 rd){
    vec2 res=vec2(-1.,-1.);
    
    float tmin=1.;
    float tmax=20.;
    
    // raytrace floor plane
    float tp1=(0.-ro.y)/rd.y;
    if(tp1>0.)
    {
        tmax=min(tmax,tp1);
        res=vec2(tp1,1.);
    }
    
    // raymarch primitives
    vec2 tb=iBox(ro-vec3(0.,.4,-.5),rd,vec3(2.5,.41,3.));
    if(tb.x<tb.y&&tb.y>0.&&tb.x<tmax)
    {
        tmin=max(tb.x,tmin);
        tmax=min(tb.y,tmax);
        
        float t=tmin;
        for(int i=0;i<70&&t<tmax;i++)
        {
            vec2 h=map(ro+rd*t);
            if(abs(h.x)<(.0001*t))
            {
                res=vec2(t,h.y);
                break;
            }
            t+=h.x;
        }
    }
    
    return res;
}

vec3 calcNormal(vec3 pos,float eps){
    const vec3 v1=vec3(1.,-1.,-1.);
    const vec3 v2=vec3(-1.,-1.,1.);
    const vec3 v3=vec3(-1.,1.,-1.);
    const vec3 v4=vec3(1.,1.,1.);
    
    return normalize(v1*map(pos+v1*eps).x+
    v2*map(pos+v2*eps).x+
    v3*map(pos+v3*eps).x+
    v4*map(pos+v4*eps).x);
}

vec3 calcNormal(vec3 pos){
    return calcNormal(pos,.002);
}

float softshadow(in vec3 ro,in vec3 rd,in float mint,in float tmax)
{
    float res=1.;
    float t=mint;
    for(int i=0;i<16;i++)
    {
        float h=map(ro+rd*t).x;
        res=min(res,8.*h/t);
        t+=clamp(h,.02,.10);
        if(h<.001||t>tmax)break;
    }
    return clamp(res,0.,1.);
}

float ao(in vec3 pos,in vec3 nor)
{
    float occ=0.;
    float sca=1.;
    for(int i=0;i<5;i++)
    {
        float hr=.01+.12*float(i)/4.;
        vec3 aopos=nor*hr+pos;
        float dd=map(aopos).x;
        occ+=-(dd-hr)*sca;
        sca*=.95;
    }
    return clamp(1.-3.*occ,0.,1.);
}

vec3 material(in vec3 col,in vec3 pos,in float m,in vec3 nor){
    // common material
    col=.2+.2*sin(m*2.+vec3(0.,1.,2.));
    
    // checkers
    if(m<1.5){
        float f=checkersGradBox(pos.xz*3.);
        col=.15+f*vec3(.05);
    }
    
    // triplanar mapping
    if(m==23.56){
        vec3 triMap=triplanarMapping(iChannel0,nor,pos);
        col=triMap;
    }
    
    return col;
}

vec3 lighting(in vec3 col,in vec3 pos,in vec3 rd,in vec3 nor){
    vec3 lin=vec3(0.);
    
    // reflection
    vec3 ref=reflect(rd,nor);
    
    // ao
    float occ=ao(pos,nor);
    
    // sun
    {
        // pos
        vec3 lig=normalize(vec3(-.5,.4,-.6));
        // dir
        vec3 hal=normalize(lig-rd);
        // diffuse
        float dif=diffuse(nor,lig);
        // softshadow
        dif*=softshadow(pos,lig,.02,2.5);
        // specular
        float spe=specular(nor,hal,16.);
        spe*=dif;
        // fresnel
        spe*=fresnel(.04,.96,5.,-lig,hal);
        // apply
        lin+=col*2.20*dif*vec3(1.30,1.,.70);
        lin+=5.*spe*vec3(1.30,1.,.70);
    }
    // sky
    {
        // diffuse
        float dif=sqrt(saturate_1(.5+.5*nor.y));
        // ao
        dif*=occ;
        // specular
        float spe=smoothstep(-.2,.2,ref.y);
        spe*=dif;
        // fresnel
        spe*=fresnel(.04,.96,5.,rd,nor);
        // softshadow
        spe*=softshadow(pos,ref,.02,2.5);
        // apply
        lin+=col*.60*dif*vec3(.40,.60,1.15);
        lin+=2.*spe*vec3(.40,.60,1.30);
    }
    // back
    {
        // diff
        float dif=diffuse(nor,normalize(vec3(.5,0.,.6)))*saturate_1(1.-pos.y);
        // ao
        dif*=occ;
        // apply
        lin+=col*.55*dif*vec3(.25,.25,.25);
    }
    // sss
    {
        // fresnel
        float dif=fresnel(0.,1.,2.,rd,nor);
        // ao
        dif*=occ;
        // apply
        lin+=col*.25*dif*vec3(1.,1.,1.);
    }
    
    return lin;
}

vec3 render(in vec3 ro,in vec3 rd){
    // skybox
    vec3 col=vec3(.7,.7,.9)-max(rd.y,0.)*.3;
    
    // raymarching
    vec2 res=raycast(ro,rd);
    float t=res.x;
    float m=res.y;
    
    if(m>-.5){
        // position
        vec3 pos=ro+t*rd;
        // normal
        vec3 nor=(m<1.5)?vec3(0.,1.,0.):calcNormal(pos);
        
        // material
        col=material(col,pos,m,nor);
        
        // lighting
        col=lighting(col,pos,rd,nor);
        
        // fog
        col=mix(col,vec3(.7,.7,.9),fogFactorExp(t*t*t,.0001));
    }
    
    return col;
}

vec3 getSceneColor(vec2 fragCoord){
    // pixel coordinates
    vec2 p=normalizeScreenCoords(fragCoord,iResolution.xy);
    
    // mouse
    vec2 mo=iMouse.xy/iResolution.xy;
    
    // time
    float time=32.+iTime*1.5;
    
    // camera
    // look-at target
    vec3 ta=vec3(.5,-.5,-.6);
    
    // ray origin
    // vec3 ro=ta+vec3(4.5*cos(7.*mo.x),1.3+2.*mo.y,4.5*sin(7.*mo.x));
    vec3 ro=ta+vec3(4.5*cos(.1*time+7.*mo.x),1.3+2.*mo.y,4.5*sin(.1*time+7.*mo.x));
    
    // focal length
    const float fl=2.5;
    
    // ray direction
    vec3 rd=getRayDirection(p,ro,ta,fl);
    
    // render
    vec3 col=render(ro,rd);
    
    // gamma
    col=toGamma(col);
    
    return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec3 col=getSceneColor(fragCoord);
    
    fragColor=vec4(col,1.);
}