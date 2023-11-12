package matching;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import matching.ChainNode;
import flixel.FlxG;
import flixel.math.FlxPoint;
import bitdecay.flixel.debug.DebugDraw;
import input.SimpleController;
import flixel.FlxSprite;

class MatchBoard extends FlxTypedGroup<FlxSprite> {
	private static var FAST_FALL_MOD = 10.0;

	private static var MOVE_REPEAT_INTERVAL = 0.25;

	private var moveHoldTimer = 0.0;

	private var boardWidth = 6;
	private var boardHeight = 12;
	public static var CELL_SIZE = 16;
	var board = new Array<Array<MatchPiece>>();

	// lets us know if the game is currently 'active' for the player, or if animations and such are playing
	var playActive = true;

	var activePair:MatchPair;
	var fullySettled:Bool = false;

	var chains:Array<ChainNode> = [];

	var comboCount = 0;

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
		add(activePair.a);
		add(activePair.b);
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
			if (SimpleController.pressed(LEFT)) {
				moveHoldTimer += elapsed;
				if (moveHoldTimer >= MOVE_REPEAT_INTERVAL) {
					moveHoldTimer -= MOVE_REPEAT_INTERVAL;
					// TODO: Consolidate this small move check
					if (activePair.moveLeft()) {
						// great!
					} else {
						// can't move
					}
				}
			} else if (SimpleController.pressed(RIGHT)) {
				moveHoldTimer += elapsed;
				if (moveHoldTimer >= MOVE_REPEAT_INTERVAL) {
					moveHoldTimer -= MOVE_REPEAT_INTERVAL;
					// TODO: Consolidate this small move check
					if (activePair.moveRight()) {
						// great!
					} else {
						// can't move
					}
				}
			} else {
				moveHoldTimer = 0;
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

				// reset our settled flag to ensure chains are checked
				fullySettled = false;
			}
		} else if (fullySettled && playActive) {
			sendPiece();
		}

		checkSettled();

		#if debug
		debugDraw();
		#end

		for (chain in chains) {
			#if debug
			chain.debugDraw();
			#end
		}
	}
	function debugDraw() {
		for (x in 0...board.length) {
			for (y in 0...board[x].length) {
				if (board[x][y] != null) {
					DebugDraw.ME.drawWorldCircle(x * CELL_SIZE, y * CELL_SIZE, 3);
				}
			}
		}
	}
	
	function clearChain(chain:ChainNode) {
		playActive = false;

		// TODO: need to do animations / wait for animation to finish before continuing game
		var first = true;
		chain.forEachNode((piece) -> {
			// TODO: We need to visit neighbors of the node to 'break' any armor / interact with special pieces
			FlxTween.tween(piece, {alpha: 0}, {
				onComplete: (t) -> {
					board[piece.cx][piece.cy] = null;
					FlxG.state.remove(piece);

					if (first) {
						first = false;
						// explicitly set this to false to give a chance for any further combos to carry out
						fullySettled = false;
					}
				}
			});
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

				updatePieceSettled(piece);
				if (!piece.settled) {
					piece.yVel += gravity;
					if (!updatePieceSettled(piece)) {
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
			// set this to true, let any subsequent chains detected set it back to false, if needed
			playActive = true;
			
			checkChains();
		}

		fullySettled = settleCheck;
	}

	function updatePieceSettled(piece:MatchPiece):Bool {
		if (piece.yr > 0.5 && hasCollision(piece.cx, piece.cy + 1)) {
			piece.yr = 0;
			piece.yVel = 0;
			piece.settled = true;
		} else if (!hasCollision(piece.cx, piece.cy + 1)) {
			piece.settled = false;
			var y = piece.cy;
			while (y > 0) {
				var p = board[piece.cx][y];
				if (p != null) {
					// This doesn't work as intended because the pieces still occupy the grid cell while falling, so
					// these pieces are likely having `settled` set immediately back to true until the piece under it falls
					// entirely to a new grid cell.

					// possible solutions... don't occupy a cell until a piece is settled?
					p.settled = false;
				}
				y--;
			}
		}
		return piece.settled;
	}

	function checkChains() {
		chains = [];
		var checked:Array<MatchPiece> = [];
		for (column in board) {
			for (y in 0...column.length) {
				var piece = column[y];
				if (piece != null && !checked.contains(piece)) {
					// find all adjacent pieces that match recursively
					var chain = findConnected(new ChainNode(piece), []);
					chain.addPiecesTo(checked);

					if (chain.count() > 1) {
						chains.push(chain);
					}
				}
			}
		}

		var breaks:Array<ChainNode> = [];
		for (chain in chains) {
			if (chain.count() >= 4) {
				breaks.push(chain);
			}
		}

		if (breaks.length > 0) {
			comboCount++;
			score(breaks);
			for (chain in breaks) {
				clearChain(chain);
				chains.remove(chain); // does this break the iterator?
			}
			QuickLog.notice('Combo: $comboCount');
		} else {
			// reset combo counter if nothing breaks
			if (comboCount != 0) {
				QuickLog.notice('---Combo reset---');
			}
			comboCount = 0;
		}
	}

	function score(breaks:Array<ChainNode>) {
		var baseScore = 0;
		for (chain in breaks) {
			baseScore += Scoring.baseScore(chain.count());
		}
		var comboMult = Scoring.comboScalar(comboCount);
		var multiBreak = Scoring.multiBreakScalar(breaks.length);
		var finalScore = baseScore * comboMult * multiBreak;
		QuickLog.notice('  Points: $finalScore ($baseScore * $comboMult * $multiBreak)');
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
			if (updatePieceSettled(b)) {
				board[b.cx][b.cy] = b;
				board[a.cx][a.cy] = a;
			}
			if (updatePieceSettled(a)) {
				board[a.cx][a.cy] = a;
				board[b.cx][b.cy] = b;
			}
		} else {
			if (updatePieceSettled(a)) {
				board[a.cx][a.cy] = a;
				board[b.cx][b.cy] = b;
			}
			if (updatePieceSettled(b)) {
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

		// falling pieces aren't considered collidable. This is useful for having a column of blocks
		// fall together if a block near the bottom breaks
		return board[cx][cy] != null && board[cx][cy].settled;
	}
}
