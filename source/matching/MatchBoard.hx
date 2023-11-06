package matching;

import matching.Chain.ChainNode;
import flixel.FlxG;
import flixel.math.FlxPoint;
import bitdecay.flixel.debug.DebugDraw;
import input.SimpleController;
import flixel.FlxSprite;

class MatchBoard extends FlxSprite {
	private static var FAST_FALL_MOD = 5.0;

	private var boardWidth = 6;
	private var boardHeight = 12;
	public static var CELL_SIZE = 16;
	var board = new Array<Array<MatchPiece>>();

	var activePair:MatchPair;
	var fullySettled:Bool = false;

	var breaks:Array<ChainNode> = [];

	var gravity = 1.0;

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
				if (activePair.moveLeft()) {
					// great!
				} else {
					// can't move
				}
			}
			if (SimpleController.just_pressed(RIGHT)) {
				if (activePair.moveRight()) {
					// great!
				} else {
					// can't move
				}
			}
			if (SimpleController.just_pressed(A)) {
				if (activePair.spin()) {
					// great!
				} else {
					// can't spin
				}
			}

			activePair.adjust(0, gravity * elapsed * (SimpleController.pressed(DOWN) ? FAST_FALL_MOD : 1));

			if (checkPairControlDone()) {
				// trim the remainder to avoid jitters when breaking the pieces apart
				activePair.a.yr = 0;
				activePair.b.yr = 0;

				activePair.finish();
				activePair = null;

				// reset our settled flag to ensure breaks are checked
				fullySettled = false;
			}
		} else if (fullySettled) {
			sendPiece();
		}

		checkSettled();

		for (chain in breaks) {
			#if debug
			chain.debugDraw();
			#end

			if (chain.count() >= 4) {
				clearChain(chain);
				breaks.remove(chain); // does this break the iterator?
			}
		}
	}
	function clearChain(chain:ChainNode) {
		// TODO: need to do animations / wait for animation to finish before continuing game
		chain.forEachNode((piece) -> {
			board[piece.cx][piece.cy] = null;
			FlxG.state.remove(piece);
		});
	}
	

	function checkSettled() {
		var settleCheck = true;
		for (column in board) {
			for (y in 0...column.length) {
				var cell = column.length - 1 - y;
				var piece = column[cell];
				if (piece == null) {
					continue;
				}

				piece.checkSettled();
				if (!piece.settled) {
					piece.yVel += gravity;
					if (!piece.checkSettled()) {
						// XXX: This just feels like it has potential to be buggy
						board[piece.cx][piece.cy] = null;
						piece.updateCoords();
						board[piece.cx][piece.cy] = piece;
						settleCheck = false;
					}
				}
			}
		}

		if (!fullySettled && settleCheck) {
			// TODO: Check for breaks and do all animations
			checkBreaks();
		}

		fullySettled = settleCheck;
	}

	function checkBreaks() {
		breaks = [];
		var checked:Array<MatchPiece> = [];
		for (column in board) {
			for (y in 0...column.length) {
				var piece = column[y];
				if (piece != null && !checked.contains(piece)) {
					// find all adjacent pieces that match recursively
					var chain = findConnected(new ChainNode(piece), []);
					chain.addPiecesTo(checked);

					if (chain.count() > 1) {
						breaks.push(chain);
					}
				}
			}
		}
	}

	function findConnected(chain:ChainNode = null, visited:Array<MatchPiece>):ChainNode {
		visited.push(chain.piece);

		// our 4 adjacent pieces
		var adjacent = [
			getBoardPiece(chain.piece.cx, chain.piece.cy - 1),
			getBoardPiece(chain.piece.cx, chain.piece.cy + 1),
			getBoardPiece(chain.piece.cx - 1, chain.piece.cy),
			getBoardPiece(chain.piece.cx + 1, chain.piece.cy),
		];

		for (adj in adjacent) {
			if (adj != null && !visited.contains(adj)) {
				if (adj.type == chain.piece.type) {
					var next = chain.ConnectTo(adj);
					findConnected(next, visited);
				}
			}
		}

		return chain;
	}

	function getBoardPiece(cx:Int, cy:Int):MatchPiece {
		if (cx < 0 || cx >= board.length || cy < 0 || cy >= board[0].length) {
			return null;
		}
		
		return board[cx][cy];
	}

	function checkPairControlDone() {
		var a = activePair.a;
		var b = activePair.b;
		// Check bottom-up so we proprogate the settled-ness properly
		if (b.cy > a.cy) {
			if (b.checkSettled()) {
				board[b.cx][b.cy] = b;
				board[a.cx][a.cy] = a;
			}
			if (a.checkSettled()) {
				board[a.cx][a.cy] = a;
				board[b.cx][b.cy] = b;
			}
		} else {
			if (a.checkSettled()) {
				board[a.cx][a.cy] = a;
				board[b.cx][b.cy] = b;
			}
			if (b.checkSettled()) {
				board[a.cx][a.cy] = a;
				board[b.cx][b.cy] = b;
			}
		}
		return a.settled || b.settled;
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
