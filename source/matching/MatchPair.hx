package matching;

import flixel.math.FlxPoint;
import bitdecay.flixel.spacial.Cardinal;
import flixel.math.FlxMath;

// Pairs are always anchored around piece 'a'
class MatchPair {
	private static var LEFT_RIGHT_GIVE = 0.3;

	public var a:MatchPiece;
	public var b:MatchPiece;

	var orientation:Cardinal;

	public var left(get, null):Int;
	public var right(get, null):Int;

	public function new(a:MatchPiece, b:MatchPiece, p:FlxPoint) {
		this.a = a;
		this.b = b;
		a.sibling = b;
		b.sibling = a;

		a.cx = Math.floor(p.x);
		a.cy = Math.floor(p.y);

		b.cx = a.cx;
		b.cy = a.cy - 1;
		orientation = N;
	}

	function get_left():Int {
		return FlxMath.minInt(a.cx, b.cx);
	}

	function get_right():Int {
		return FlxMath.maxInt(a.cx, b.cx);
	}

	public function shift(dir:Cardinal) {
		switch(dir) {
			case E:
				a.cx--;
				b.cx--;
			case W:
				a.cx++;
				b.cx++;
			default:
		}
	}

	// clockwise spin
	public function spin():Bool {
		// TODO: Animations for this? Tweens? Pause game while spin happens?
		var nextOrient = FlxMath.wrap(orientation + 90, 0, 359);
		var spinSuccess = true;
		switch(nextOrient) {
			case E:
				/*
				* |b|
				* |a|   ->  |a b|
				*/
				if (!a.parent.hasCollision(a.cx + 1, a.cy)) {
					// standard spin
					b.cx = a.cx + 1;
					b.cy = a.cy;
				} else if (!a.parent.hasCollision(a.cx - 1, a.cy)) {
					// against a blocker, a moves away from blocker, b takes its place
					b.cx = a.cx;
					b.cy = a.cy;
					a.cx--;
				} else {
					// both sides blocked, can't spin
					// TODO: Do we want to allow the piece to "flip" vertically?
					spinSuccess = false;
				}
			case S:
				/*
				* |a b|  ->  |a|
				*            |b|
				*/
				if (!a.parent.hasCollision(a.cx, a.cy + 1)) {
					// standard spin
					b.cx = a.cx;
					b.cy = a.cy + 1;
				} else if (!a.parent.hasCollision(a.cx - 1, a.cy)) {
					// against a blocker, a moves away from blocker, b takes its place
					b.cx = a.cx;
					b.cy = a.cy;
					a.cy--;
				} else {
					// both sides blocked, can't spin
					// TODO: Do we want to allow the piece to "flip" vertically?
					spinSuccess = false;
				}
			case W:
				/*
				* |a|   ->  |b a|
				* |b|
				*/
				if (!a.parent.hasCollision(a.cx - 1, a.cy)) {
					// standard spin
					b.cx = a.cx - 1;
					b.cy = a.cy;
				} else if (!a.parent.hasCollision(a.cx - 1, a.cy)) {
					// against a blocker, a moves away from blocker, b takes its place
					b.cx = a.cx;
					b.cy = a.cy;
					a.cx++;
				} else {
					// both sides blocked, can't spin
					// TODO: Do we want to allow the piece to "flip" vertically?
					spinSuccess = false;
				}
			case N:
				/*
				*        ->  |b|
				* |b a|      |a|
				*
				*/
				if (!a.parent.hasCollision(a.cx - 1, a.cy)) {
					// standard spin
					b.cx = a.cx;
					b.cy = a.cy - 1;
				} else if (!a.parent.hasCollision(a.cx - 1, a.cy)) {
					// against a blocker, a moves away from blocker, b takes its place
					b.cx = a.cx;
					b.cy = a.cy;
					a.cx++;
				} else {
					// both sides blocked, can't spin
					// TODO: Do we want to allow the piece to "flip" vertically?
					spinSuccess = false;
				}
			default:
				spinSuccess = false;
		}

		if (spinSuccess) {
			orientation = nextOrient;
		}

		return spinSuccess;
	}
	public function finish() {
		a.sibling = null;
		b.sibling = null;
	}
	

	public function adjust(x:Float, y:Float) {
		a.xr += x;
		a.yr += y;
		b.xr += x;
		b.yr += y;

		a.updateCoords();
		b.updateCoords();
	}

	public function moveLeft():Bool {
		var acy = a.cy + (a.yr > LEFT_RIGHT_GIVE ? 1 : 0);
		var bcy = b.cy + (b.yr > LEFT_RIGHT_GIVE ? 1 : 0);
		if (!a.parent.hasCollision(left - 1, acy) && !b.parent.hasCollision(left - 1, bcy)) {
			adjust(-1, 0);
			return true;
		} else {
			return false;
		}
	}

	public function moveRight():Bool {
		var acy = a.cy + (a.yr > LEFT_RIGHT_GIVE ? 1 : 0);
		var bcy = b.cy + (b.yr > LEFT_RIGHT_GIVE ? 1 : 0);
		if (!a.parent.hasCollision(right + 1, acy) && !b.parent.hasCollision(right + 1, bcy)) {
			adjust(1, 0);
			return true;
		} else {
			return false;
		}
	}
}