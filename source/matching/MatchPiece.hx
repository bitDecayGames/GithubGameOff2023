package matching;

import flixel.FlxG;
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

	public var yVel = 0.0;

	public var settled = false;

	public var parent:MatchBoard;

	public var sibling:MatchPiece = null;

	public var type:PieceType;

	var gfxRow = 0;

	static var popFrames = [16, 17, 18, 19];

	public function new(board:MatchBoard) {
		super();

		parent = board;
		this.type = PieceType.random();

		loadGraphic(AssetPaths.aliens__png, true, 16, 16);

		switch(type) {
			case A:
				gfxRow = 0;
			case B:
				gfxRow = 1;
			case C:
				gfxRow = 2;
			case D:
				gfxRow = 3;
		}

		var baseFrame = gfxRow * 20;

		animation.add('idle', [baseFrame + 1]);
		animation.add('pop', [for (i in popFrames) baseFrame + i], false);

		animation.play('idle');

		this.centerOrigin();
	}

	override public function update(delta:Float) {

		yr += yVel * delta;
		
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

		DebugDraw.ME.drawWorldCircle(x + MatchBoard.CELL_SIZE / 2, y + MatchBoard.CELL_SIZE / 2, MatchBoard.CELL_SIZE / 2, PUZZLE, settled ? FlxColor.GRAY : FlxColor.MAGENTA);

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

	// public function checkSettled():Bool {
	// 	if (yr > 0.5 && parent.hasCollision(cx, cy + 1)) {
	// 		yr = 0;
	// 		yVel = 0;
	// 		settled = true;
	// 	} else if (!parent.hasCollision(cx, cy + 1)) {
	// 		settled = false;
	// 		parent.unsettleUp(cx, cy);
	// 	}
	// 	return settled;
	// }
}