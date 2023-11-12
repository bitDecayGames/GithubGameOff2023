package orbit;

import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Body extends FlxSprite {
	public var weight:Float = 1.0;

	public var radius:Float;

	// var dt = 0.0;

	// var savedLast:FlxPoint = FlxPoint.get();

	public function new(size:Float, x:Float, y:Float) {
		super(x, y);
		radius = size;

		makeGraphic(Std.int(size), Std.int(size));

		weight = size * size;

		// savedLast.set(x, y);
	}

	// override function update(elapsed:Float) {
	// 	dt += elapsed;
	// 	if (dt > OrbitSystem.STEP_SIZE) {
	// 		dt -= OrbitSystem.STEP_SIZE;
	// 		setPosition(savedLast.x, savedLast.y);
	// 		super.update(OrbitSystem.STEP_SIZE);
	// 		savedLast.set(x, y);
	// 	} else {
	// 		// let our position be interpretted
	// 		super.update(elapsed);
	// 	}
	// }
}