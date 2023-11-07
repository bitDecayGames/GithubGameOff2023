package orbit;

import states.OrbitalState;
import bitdecay.flixel.debug.DebugDraw;
import flixel.math.FlxPoint;
import flixel.FlxBasic;

class OrbitSystem extends FlxBasic {
	// static things in the system
	public var bodies:Array<Body> = [];

	// dynamic things in the system, affected by bodies
	public var actors:Array<Body> = [];

	// G-factor of the gravity calculations
	public var systemG = 100;

	public function new() {
		super();
	}

	var tmp1 = FlxPoint.get();
	var tmp2 = FlxPoint.get();
	var tmp3 = FlxPoint.get();

	override function update(elapsed:Float) {
		super.update(elapsed);

		for (actor in actors) {
			actor.getMidpoint(tmp1);
			tmp3.copyFrom(tmp1);
			for (body in bodies) {
				body.getMidpoint(tmp2);
				var force = (systemG * actor.weight * body.weight) / tmp1.distSquared(tmp2);

				tmp2.subtractPoint(tmp1).normalize().scale(force);
				tmp3.addPoint(tmp2);
				tmp2.scale(elapsed);
				actor.velocity.addPoint(tmp2);
			}

			#if debug
			DebugDraw.ME.drawWorldLine(OrbitalState.ME.systemCam, tmp1.x, tmp1.y, tmp3.x, tmp3.y, ORBIT);
			#end
		}
	}
}