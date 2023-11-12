package states;

import flixel.FlxSubState;
import matching.MatchBoard;
import entities.Item;
import flixel.util.FlxColor;
import debug.DebugLayers;
import achievements.Achievements;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import bitdecay.flixel.debug.DebugDraw;

using states.FlxStateExt;

class PuzzleState extends FlxSubState {
	var board:MatchBoard;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();
		bgColor = FlxColor.BLACK;

		FlxG.camera.pixelPerfectRender = true;

		board = new MatchBoard();
		add(board);

		board.sendPiece();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
