package states;

import openfl.filters.ShaderFilter;
import openfl.display.Shader;
import input.SimpleController;
import flixel.math.FlxPoint;
import orbit.Launcher;
import orbit.Body;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import orbit.OrbitSystem;
import flixel.FlxG;
import flixel.FlxState;
import shaders.ExampleShader;

using bitdecay.flixel.extensions.FlxPointExt;

class OrbitalState extends FlxState {

	public static var ME:OrbitalState;

	var launcher:Launcher;

	public var orbitalSystem:OrbitSystem;

	public var systemCam:FlxCamera;

	public var orbitShader:ExampleShader;

	public function new() {
		super();
		ME = this;
	}

	override public function create() {
		super.create();
		FlxG.camera.pixelPerfectRender = true;

		orbitShader = new ExampleShader();

		systemCam = new FlxCamera(50, 50, 300, 300);
		systemCam.bgColor = FlxColor.PURPLE.getDarkened(0.8);
		FlxG.cameras.add(systemCam, false);
		systemCam.filters = [new ShaderFilter(orbitShader)];
		// FlxG.cameras.setDefaultDrawTarget(FlxG.camera, false);

		orbitalSystem = new OrbitSystem(FlxPoint.get(systemCam.width/2, systemCam.height/2), 50);
		orbitalSystem.orbitCb = handleOrbit;
		add(orbitalSystem);

		var planet = new Body(10, 50, 50);
		orbitalSystem.bodies.push(planet);
		planet.camera = systemCam;
		add(planet);

		orbitShader.planets = [planet];

		var planet2 = new Body(20, 150, 125);
		orbitalSystem.bodies.push(planet2);
		planet2.camera = systemCam;
		add(planet2);

		launcher = new Launcher();
		launcher.camera = systemCam;
		add(launcher);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		orbitShader.update(elapsed);

		var launchPoint = orbitalSystem.center.pointOnCircumference(launcher.restAngle, orbitalSystem.radius);
		launcher.setPositionMidpoint(launchPoint.x, launchPoint.y);
	}

	public function launchSatellite(mid:FlxPoint, angle:Float, velocity:FlxPoint) {
		var satellite = new Body(3, mid.x, mid.y);
		satellite.velocity.copyFrom(velocity);
		orbitalSystem.actors.push(satellite);
		satellite.camera = systemCam;
		add(satellite);
	}

	function handleOrbit(actor:Body, planet:Body) {
		// trace('orbit being handle');
		// systemCam.visible = false;
		// openSubState(new PuzzleState());
		// subStateClosed.addOnce((sub) -> {systemCam.visible = true;});
	}
}