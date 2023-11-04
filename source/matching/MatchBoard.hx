package matching;

import flixel.FlxG;
import flixel.math.FlxPoint;
import bitdecay.flixel.debug.DebugDraw;
import input.SimpleController;
import flixel.FlxSprite;

class MatchBoard extends FlxSprite {
	private var boardWidth = 6;
	private var boardHeight = 12;
	public static var CELL_SIZE = 16;
	var board = new Array<Array<MatchPiece>>();

	var activePair:MatchPair;

	var gravity = 2.0;

	public function new() {
		super();

		// init our board with nulls
		for (i in 0...boardWidth) {
			board.push([for (i in 0...boardHeight) { null; }]);
		}
	}

	public function sendPiece() {
		activePair = new MatchPair(new MatchPiece(this), new MatchPiece(this), FlxPoint.get(3, 0));
		FlxG.state.add(activePair.a);
		FlxG.state.add(activePair.b);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		DebugDraw.ME.drawWorldRect(0, 0, boardWidth * CELL_SIZE, boardHeight * CELL_SIZE);

		if (activePair != null) {
			if (SimpleController.just_pressed(LEFT)) {
				if (activePair.left > 0) {
					activePair.adjust(-1, 0);
				} else {
					// bump into wall
				}
			}
			if (SimpleController.just_pressed(RIGHT)) {
				if (activePair.right < boardWidth - 1) {
					activePair.adjust(1, 0);
				} else {
					// bump into wall
				}
			}
			if (SimpleController.just_pressed(A)) {
				if (activePair.spin()) {
					// great!
				} else {
					// can't spin
				}
			}

			activePair.adjust(0, gravity * elapsed);

			if (activePair.checkDone()) {
				board[activePair.a.cx][activePair.a.cy] = activePair.a;
				board[activePair.b.cx][activePair.b.cy] = activePair.b;
				activePair.finish();
				activePair = null;
			}
		}

		for (column in board) {
			for (y in 0...column.length) {
				var cell = column.length - 1 - y;
				var piece = column[cell];
				if (piece == null) {
					continue;
				}
				if (!piece.settled) {
					piece.yr += gravity * elapsed;
					if (!piece.checkSettled()) {
						// XXX: This just feels like it has potential to be buggy
						board[piece.cx][piece.cy] = null;
						piece.updateCoords();
						board[piece.cx][piece.cy] = piece;
					}
				}
			}
		}
	}

	public function hasCollision(cx:Int, cy:Int):Bool {
		if (cx < 0 || cx >= boardWidth) {
			return true;
		} else if (cy >= boardHeight) {
			return true;
		}

		return board[cx][cy] != null;
	}
}