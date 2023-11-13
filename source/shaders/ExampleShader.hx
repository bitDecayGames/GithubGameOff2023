package shaders;

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
        // uniform ved3 planet2;

        void main()
        {
            vec2 iResolution = openfl_TextureSize;
            vec2 uv = openfl_TextureCoordv;
            vec2 fragCoord = uv * iResolution;
            
            vec4 col = texture2D(bitmap, uv);

            gl_FragColor = col;

            if (planet1.x != 0. && planet1.y != 0.) {
                if (distance(fragCoord.xy, planet1.xy) < 50.) {
                    // if (distance(fragCoord.xy, planet1.xy) - planet1.z < 50) {
                    gl_FragColor = vec4(1.,1.,1.,1.);
                }
            }

            // if (fragCoord.x <= 50.) {
            //     gl_FragColor = vec4(1.,1.,1.,1.);
            // }
        }
    ')

    public function new() {
        super();
    }

    public function update(elapsed:Float)
    {
        if (planets != null) {
            if (planets.length > 0) {
                planet1.value = [planets[0].x, planets[0].y, planets[0].radius * 2];
            }
        }
    }
}