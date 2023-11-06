package matching;

import flixel.math.FlxMath;

class Scoring {

	// score based on number of pieces connected together upon break
	private static var baseBreakScore = [
		4 => 10,
		5 => 15,
		6 => 20,
		7 => 30,
		8 => 40,
		9 => 50,
		10 => 60,
		11 => 70,
		12 => 100, // this is theoretically the largest break you can form (I think...)
	];

	// muliplier based on number of breaks combo'd together without dropping new pieces into the board
	private static var comboMultiplier = [
		1 => 1,
		2 => 1.2,
		3 => 1.5,
		4 => 2,
		5 => 3, // max combo multiplier
	];

	/* multiplier based on making multiple breaks at the same time
	 * Example mutibreak '2':
	 *       |a|b|
	 *         |
	 *         V
	 * |a|a|a|   |b|b|b|
	 */
	private static var multibreakMultiplier = [
		1 => 1,
		2 => 1.1,
		3 => 1.2,
		4 => 1.5, // max multibreak multiplier (do we want this?)
	];

	public static function baseScore(n:Int):Int {
		return baseBreakScore.get(Std.int(FlxMath.bound(n, 4, 12)));
	}

	public static function comboScalar(n:Int) {
		return comboMultiplier.get(Std.int(FlxMath.bound(n, 1, 5)));
	}

	public static function multiBreakScalar(n:Int) {
		return multibreakMultiplier.get(Std.int(FlxMath.bound(n, 1, 4)));
	}
}