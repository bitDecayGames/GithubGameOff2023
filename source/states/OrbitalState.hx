package states;

import orbit.Body;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import orbit.OrbitSystem;
import flixel.FlxG;
import flixel.FlxState;

class OrbitalState extends FlxState {

	public static var ME:OrbitalState;

	var orbitalSystem:OrbitSystem;

	public var systemCam:FlxCamera;

	public function new() {
		super();
		ME = this;
	}

	override public function create() {
		super.create();
		FlxG.camera.pixelPerfectRender = true;

		systemCam = new FlxCamera(50, 50, 300, 300);
		systemCam.bgColor = FlxColor.PURPLE.getDarkened(0.8);
		FlxG.cameras.add(systemCam);
		FlxG.cameras.setDefaultDrawTarget(FlxG.camera, false);

		orbitalSystem = new OrbitSystem();
		add(orbitalSystem);

		var planet = new Body(10, 50, 50);
		orbitalSystem.bodies.push(planet);
		add(planet);

		var planet2 = new Body(20, 150, 125);
		orbitalSystem.bodies.push(planet2);
		add(planet2);

		var satellite = new Body(3, 55, 10);
		satellite.velocity.set(40, 20);
		orbitalSystem.actors.push(satellite);
		add(satellite);

		FlxG.watch.add(satellite, "x", "X:");
		FlxG.watch.add(satellite, "y", "Y:");
		FlxG.watch.add(satellite, "velocity", "Velocity:");
	}
}