package matching;

import flixel.FlxG;
import flixel.util.FlxColor;

enum abstract PieceType(FlxColor) to FlxColor {
	var A = FlxColor.GREEN;
	var B = FlxColor.ORANGE;
	var C = FlxColor.BLUE;
	var D = FlxColor.CYAN;

	public static function random():PieceType {
		return switch(FlxG.random.int(0, 3)) {
			case 0:
				A;
			case 1:
				B;
			case 2:
				C;
			default:
				D;
		}
	}
}