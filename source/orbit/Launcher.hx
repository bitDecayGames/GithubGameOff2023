package orbit;

import flixel.math.FlxMath;
import bitdecay.flixel.debug.DebugDraw;
import flixel.math.FlxPoint;
import states.OrbitalState;
import states.PuzzleState;
import input.SimpleController;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Launcher extends FlxSprite {

	public var restAngle = 0.0;
	public var moveSpeed = 50.0;

	public var aimAngle = 0.0;
	public var aimCenterAngle = 0.0;
	public var aimConeWidth = 115.0;
	public var aimAngleChangeSpeed = 50.0;
	var aimClockwise = true;

	// a percent
	public var aimPower = 50.0;
	public var aimMaxPower = 150.0;
	public var powerChangeSpeed = 2.0;
	var powerIncreasing = true;

	

	private static var convert = 180.0 / Math.PI;

	var phase:LaunchPhase;

	public function new() {
		super();

		phase = MOVE;

		makeGraphic(10, 10, FlxColor.RED);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		switch(phase) {
			case MOVE:
				color = FlxColor.WHITE;
				if (SimpleController.pressed(LEFT)) {
					restAngle -= moveSpeed * elapsed / OrbitalState.ME.orbitalSystem.radius * convert;
				}
				if (SimpleController.pressed(RIGHT)) {
					restAngle += moveSpeed * elapsed / OrbitalState.ME.orbitalSystem.radius * convert;
				}

				if (SimpleController.just_pressed(A)) {
					phase = AIM;
					var tmp = getMidpoint(FlxPoint.get());
					var tmp2 = OrbitalState.ME.orbitalSystem.center.copyTo(FlxPoint.get());
					aimCenterAngle = tmp2.subtractPoint(tmp).degrees;
					aimAngle = aimCenterAngle;
					tmp.put();
					tmp2.put();
				}
			case AIM:
				color = FlxColor.BLUE;
				// figure aim angle

				if (aimClockwise) {
					aimAngle += aimAngleChangeSpeed * elapsed;
				} else {
					aimAngle -= aimAngleChangeSpeed * elapsed;
				}

				if (aimAngle <= aimCenterAngle - aimConeWidth) {
					aimAngle = aimCenterAngle - aimConeWidth;
					aimClockwise = !aimClockwise;
				} else if (aimAngle >= aimCenterAngle + aimConeWidth) {
					aimAngle = aimCenterAngle + aimConeWidth;
					aimClockwise = !aimClockwise;
				}

				#if debug
				var midpt = getMidpoint(FlxPoint.get());
				var aim = FlxPoint.get(1, 0);
				aim.rotateByDegrees(aimAngle);
				aim.scale(20);
				DebugDraw.ME.drawWorldLine(OrbitalState.ME.systemCam, midpt.x, midpt.y, midpt.x + aim.x, midpt.y + aim.y, ORBIT);
				DebugDraw.ME.drawWorldCircle(OrbitalState.ME.systemCam, midpt.x + aim.x, midpt.y + aim.y, 1, ORBIT);
				#end

				if (SimpleController.just_pressed(A)) {
					phase = POWER;
				} else if (SimpleController.just_pressed(B)) {
					phase = MOVE;
				}
			case POWER:
				// figure launch power
				if (powerIncreasing) {
					aimPower += powerChangeSpeed * elapsed;
				} else {
					aimPower -= powerChangeSpeed * elapsed;
				}

				if (aimPower > 1 || aimPower < 0) {
					powerIncreasing = !powerIncreasing;
					aimPower = FlxMath.bound(aimPower, 0, 1);
				}

				#if debug
				var midpt = getMidpoint(FlxPoint.get());
				var aim = FlxPoint.get(1, 0);
				aim.rotateByDegrees(aimAngle);
				var powerDot = FlxPoint.get().copyFrom(aim);
				powerDot.scale(20 * aimPower); 
				aim.scale(20);
				DebugDraw.ME.drawWorldLine(OrbitalState.ME.systemCam, midpt.x, midpt.y, midpt.x + aim.x, midpt.y + aim.y, ORBIT);
				DebugDraw.ME.drawWorldCircle(OrbitalState.ME.systemCam, midpt.x + powerDot.x, midpt.y + powerDot.y, 1, ORBIT);
				#end

				if (SimpleController.just_pressed(A)) {
					// TODO: 
					// phase = OBSERVE;
					phase = MOVE;
					var mid = getMidpoint();
					var vel = FlxPoint.get(1, 0);
					vel.rotateByDegrees(aimAngle);
					vel.scale(aimMaxPower * aimPower);
					OrbitalState.ME.launchSatellite(mid, aimAngle, vel);
					mid.put();
				} else if (SimpleController.just_pressed(B)) {
					phase = AIM;
				}
			case OBSERVE:
				// wait for result
		}
	}
}