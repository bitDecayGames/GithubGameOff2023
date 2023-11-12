package matching;

import bitdecay.flixel.debug.DebugDraw;

class ChainNode {
	public var piece:MatchPiece;

	public var connections:Array<ChainNode> = [];

	public function new(p:MatchPiece) {
		piece = p;
	}

	public function ConnectTo(piece:MatchPiece):ChainNode {
		var node = new ChainNode(piece);
		connections.push(node);
		return node;
	}

	#if debug
	public function debugDraw() {
		var me = piece;
		DebugDraw.ME.drawWorldCircle(
			(me.cx + .5) * MatchBoard.CELL_SIZE,
			(me.cy + .5) * MatchBoard.CELL_SIZE,
			5);
		for (node in connections) {
			var nxt = node.piece;
			DebugDraw.ME.drawWorldLine(
				(me.cx + .5) * MatchBoard.CELL_SIZE,
				(me.cy + .5) * MatchBoard.CELL_SIZE,
				(nxt.cx + .5) * MatchBoard.CELL_SIZE,
				(nxt.cy + .5) * MatchBoard.CELL_SIZE);
			node.debugDraw();
		}
	}
	#end

	public function addPiecesTo(dest:Array<MatchPiece>) {
		dest.push(piece);
		for (node in connections) {
			node.addPiecesTo(dest);
		}
	}

	public function count():Int {
		var count = 1;
		for (node in connections) {
			count += node.count();
		}
		return count;
	}

	public function forEachNode(fn:(p:MatchPiece) -> Void) {
		fn(piece);
		for (node in connections) {
			node.forEachNode(fn);
		}
	}
}