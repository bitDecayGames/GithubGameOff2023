package shaders;

import flixel.math.FlxPoint;
import orbit.Body;

/**
 * Basic shader that shows how to pass uniforms into shaders
**/
class ExampleShader extends flixel.system.FlxAssets.FlxShader
{
    public var planets:Array<Body>;

    @:glFragmentSource('
        #pragma header

        uniform float iTime;
        uniform vec3 planet1;
        uniform vec3 planet2;

        vec4 drawRing(vec2 fragCoord, vec3 planet, vec4 inColor) {
            if (planet.x != 0. && planet.y != 0.) {
                float dist = abs(distance(fragCoord.xy, planet.xy) - planet.z);
                if (dist < 1.) {
                    float bright = 1. - dist;
                    inColor = vec4(bright, bright, bright, 1.);
                }
            }

            return inColor;
        }

        void main()
        {
            vec2 iResolution = openfl_TextureSize;
            vec2 uv = openfl_TextureCoordv;
            vec2 fragCoord = uv * iResolution;

            vec4 col = texture2D(bitmap, uv);

            if (planet1.x != 0. && planet1.y != 0.) {
                col = drawRing(fragCoord, planet1, col);
            }

            if (planet2.x != 0. && planet2.y != 0.) {
                col = drawRing(fragCoord, planet2, col);
            }

            gl_FragColor = col;
        }
    ')

    public function new() {
        super();
    }

    public function update(elapsed:Float)
    {
        if (planets == null) {
            return;
        }

        for (i in 0...10) {
            if (planets.length > i) {
                var midPoint = FlxPoint.get();
                planets[i].getMidpoint(midPoint);
                switch(i) {
                    case 0:
                        planet1.value = [midPoint.x, midPoint.y, planets[i].radius * 2];
                    case 1:
                        planet2.value = [midPoint.x, midPoint.y, planets[i].radius * 2];
                    default:
                }
            }
        }
    }
}