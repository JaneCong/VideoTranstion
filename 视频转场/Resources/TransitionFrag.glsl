varying highp vec2 texCoordVarying;
precision mediump float;
uniform sampler2D from;

uniform sampler2D to;

uniform  int type;

uniform float alpha;
uniform highp float progress;
uniform float squareSizeFactor;
highp float rand (highp vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
vec2 circlePoint( float ang )
{
    ang += 6.28318 * 0.15;
    return vec2( cos(ang), sin(ang) );
}

float cross2d( vec2 a, vec2 b )
{
    return ( a.x * b.y - a.y * b.x );
}

float star( vec2 p, float size )
{
    if( size <= 0.0 )
    {
        return 0.0;
    }
    p /= size;
    
    vec2 p0 = circlePoint( 0.0 );
    vec2 p1 = circlePoint( 6.28318 * 1.0 / 5.0 );
    vec2 p2 = circlePoint( 6.28318 * 2.0 / 5.0 );
    vec2 p3 = circlePoint( 6.28318 * 3.0 / 5.0 );
    vec2 p4 = circlePoint( 6.28318 * 4.0 / 5.0 );
    
    float s0 = ( cross2d( p1 - p0, p - p0 ) );
    float s1 = ( cross2d( p2 - p1, p - p1 ) );
    float s2 = ( cross2d( p3 - p2, p - p2 ) );
    float s3 = ( cross2d( p4 - p3, p - p3 ) );
    float s4 = ( cross2d( p0 - p4, p - p4 ) );
    
    float s5 = min( min( min( s0, s1 ), min( s2, s3 ) ), s4 );
    float s = max( 1.0 - sign( s0 * s1 * s2 * s3 * s4 ) + sign(s5), 0.0 );
    s = sign( 2.6 - length(p) ) * s;
    
    return max( s, 0.0 );
}



void main()
{
    highp vec2 p = texCoordVarying;
  
    if (type == 1) {
        vec4 fromColor = texture2D(from, p);
        vec4 toColor = texture2D(to, p);
        gl_FragColor = mix(fromColor, toColor, progress);
    }else if (type == 2){
        highp float circPos = atan(p.y - 0.5, p.x - 0.5) + progress;
        highp float modPos = mod(circPos, 3.1415 / 4.);
        highp float signed = sign(progress - modPos);
        highp float smoothed = smoothstep(0., 1., signed);
        
        if (smoothed > 0.5){
            gl_FragColor = texture2D(to, p);
        } else {
            gl_FragColor = texture2D(from, p);
        }
    }else if (type == 3){
        highp float size = 0.2;
        highp float r = rand(vec2(0, p.y));
        highp float m = smoothstep(0.0, -size, p.x*(1.0-size) + size*r - (progress * (1.0 + size)));
        gl_FragColor = mix(texture2D(from, p), texture2D(to, p), m);
    }else if (type == 4){
        vec2 dir = p - vec2(.5);
        float dist = length(dir);
        vec2 offset = dir * (sin(progress * dist * 100.0 - progress * 50.0) + .5) / 30.;
        gl_FragColor = mix(texture2D(from, p + offset), texture2D(to, p), smoothstep(0.2, 1.0, progress));
    }else if (type == 5){
        float revProgress = (1.0 - progress);
        float distFromEdges = min(progress, revProgress);
        float squareSize = (squareSizeFactor * distFromEdges) + 1.0;
        vec2 p2 = (floor((gl_FragCoord.xy + squareSize * 0.5) / squareSize) * squareSize) / (gl_FragCoord.xy/p);
        vec4 fromColor = texture2D(from, p2);
        vec4 toColor = texture2D(to, p2);
        gl_FragColor = mix(fromColor, toColor, progress);
    }else if (type == 6){
        vec4 t1=texture2D(from,vec2(pow(p.x,1.-progress),pow(p.y,1.-progress)));
        vec4 t2=texture2D(to,vec2(pow(p.x,progress),pow(p.y,progress)));
        gl_FragColor = mix(t1, t2, progress);
    }
}
