package matching;

import bitdecay.flixel.debug.DebugDraw;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class MatchPiece extends FlxSprite {
	/** Grid X coordinate **/
	public var cx = 0;
	/** Grid Y coordinate **/
	public var cy = 0;
	/** Sub-grid X coordinate (from 0.0 to 1.0) **/
	public var xr = 0.5;
	/** Sub-grid Y coordinate (from 0.0 to 1.0) **/
	public var yr = 1.0;

	public var settled = false;

	public var parent:MatchBoard;

	public var sibling:MatchPiece = null;

	public function new(board:MatchBoard) {
		super();

		parent = board;

		makeGraphic(16, 16, FlxColor.YELLOW);
		this.centerOrigin();
	}

	override public function update(delta:Float) {
		
		// x is adjusted so that pieces are centered in the grid cell at 0.5
		x = (cx + xr - .5) * MatchBoard.CELL_SIZE;

		// This gives us our travel grace period before things settle, but doesn't make the rendering weird
		// where pieces fall and "snap" back to a settle position
		var renderYR = yr;
		if (yr > 0 && parent.hasCollision(cx, cy + 1)) {
			renderYR = 0;
		} else if (sibling != null && sibling.yr > 0 && sibling.parent.hasCollision(sibling.cx, sibling.cy + 1)) {
			renderYR = 0;
		}

		y = (cy + renderYR) * MatchBoard.CELL_SIZE;

		DebugDraw.ME.drawWorldCircle(x + MatchBoard.CELL_SIZE / 2, y + MatchBoard.CELL_SIZE / 2, MatchBoard.CELL_SIZE / 2);

		super.update(delta);
	}

	public function updateCoords():Bool {
		var changed = false;
		while (xr >= 1) {
			cx++;
			xr -= 1;
			changed = true;
		}
		while (xr < 0) {
			cx--;
			xr += 1;
			changed = true;
		}

		while (yr >= 1) {
			cy++;
			yr -= 1;
			changed = true;
		}
		while (yr < 0) {
			cy--;
			yr += 1;
			changed = true;
		}

		return changed;
	}

	public function checkSettled():Bool {
		if (yr > 0.5 && parent.hasCollision(cx, cy + 1)) {
			yr = 0;
			settled = true;
			return true;
		} else {
			return false;
		}
		// 	piece.yr = 0;
		// 	piece.settled = true;
		// piece.yr = 0;
		// piece.settled = true;
	}
}