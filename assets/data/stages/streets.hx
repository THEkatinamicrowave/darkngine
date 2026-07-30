//
import flixel.addons.display.FlxTiledSprite;

var rainShader:CustomShader;

var rainShaderStartIntensity:Float;
var rainShaderEndIntensity:Float;

var lightsStop:Bool = false;
var lastChange:Int = 0;
var changeInterval:Int = 8;

var carWaiting:Bool = false;
var carInterruptable:Bool = true;
var car2Interruptable:Bool = true;

var scrollingSky:FlxTiledSprite;

function postCreate() {
	rainShader = new CustomShader('rain');
	rainShader.uCameraBounds = [FlxG.camera.viewLeft, FlxG.camera.viewTop, FlxG.camera.viewRight, FlxG.camera.viewBottom];
	rainShader.uScale = FlxG.height / 200;
	rainShader.uIntensity = rainShaderStartIntensity;
	rainShader.uTime = 0;
	rainShader.uSpriteMode = false;
	rainShader.uRainColor = [0.4, 0.5, 0.8];
	FlxG.camera.addShader(rainShader);

	if (PlayState.instance != null) {
		switch (PlayState.instance.SONG.meta.name.toLowerCase()) {
			default:
				rainShaderStartIntensity = 0;
				rainShaderEndIntensity = 0.1;
			case "lit-up":
				rainShaderStartIntensity = 0.1;
				rainShaderEndIntensity = 0.2;
			case "2hot":
				rainShaderStartIntensity = 0.2;
				rainShaderEndIntensity = 0.4;
		}
	}

	resetCar(true, true);
	resetStageValues();
	
	scrollingSky = new FlxTiledSprite(Paths.image('stages/streets/streets/phillySkybox'), 2922, 718, true, false);
	scrollingSky.setPosition(-650, -375);
	scrollingSky.scrollFactor.set(0.1, 0.1);
	scrollingSky.scale.set(0.65, 0.65);

	PlayState.instance.insert(members.indexOf(phillySkyline), scrollingSky);
}

function postUpdate(elapsed:Float) {
	if (FlxG.sound.music != null) {
		var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, rainShaderStartIntensity, rainShaderEndIntensity);
		rainShader.uIntensity = remappedIntensityValue;
	} else {
		rainShader.uIntensity = rainShaderStartIntensity;
	}
	rainShader.uCameraBounds = [FlxG.camera.viewLeft, FlxG.camera.viewTop, FlxG.camera.viewRight, FlxG.camera.viewBottom];
	rainShader.uTime = rainShader.uTime + elapsed;

	if (scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 22;
}

function beatHit(beat:Int) {
	if (FlxG.random.bool(10) && beat != (lastChange + changeInterval) && carInterruptable == true) {
		if (lightsStop == false)
			driveCar(phillyCars);
		else
			driveCarLights(phillyCars);
	}

	if (
		FlxG.random.bool(10) &&
		beat != (lastChange + changeInterval) &&
		car2Interruptable == true &&
		lightsStop == false
	) driveCarBack(phillyCars2);

	if (beat == (lastChange + changeInterval)) changeLights(beat);
}

function onGameOver(event:GameOverEvent) {
	FlxG.camera.removeShader(rainShader);
}

function destroy() {
	if (phillyCars != null) FlxTween.cancelTweensOf(phillyCars);
	if (phillyCars2 != null) FlxTween.cancelTweensOf(phillyCars2);
}

function changeLights(beat:Int) {
	lastChange = beat;
	lightsStop = !lightsStop;

	if (lightsStop) {
		phillyTraffic.playAnim('tored');
		changeInterval = 20;
	} else {
		phillyTraffic.playAnim('togreen');
		changeInterval = 30;

		if (carWaiting == true) finishCarLights(phillyCars);
	}
}

function resetCar(left:Bool, right:Bool) {
	if (left) {
		carWaiting = false;
		carInterruptable = true;

		if (phillyCars != null) {
			FlxTween.cancelTweensOf(phillyCars);
			phillyCars.x = 1200;
			phillyCars.y = 818;
			phillyCars.angle = 0;
		}
	}

	if (right) {
		car2Interruptable = true;
		if (phillyCars2 != null) {
			FlxTween.cancelTweensOf(phillyCars2);
			phillyCars2.x = 1200;
			phillyCars2.y = 818;
			phillyCars2.angle = 0;
		}
	}
}

function finishCarLights(sprite:FunkinSprite) {
	carWaiting = false;
	var duration:Float = FlxG.random.float(1.8, 3);
	var rotations:Array<Int> = [-5, 18];
	var offset:Array<Float> = [306.6, 168.3];
	var startdelay:Float = FlxG.random.float(0.2, 1.2);

	var path:Array<FlxPoint> = [
		FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
		FlxPoint.get(3102 - offset[0], 1187 - offset[1] + 40)
	];

	FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay});
	FlxTween.quadPath(sprite, path, duration, true, {
		ease: FlxEase.sineIn,
		startDelay: startdelay,
		onComplete: () -> carInterruptable = true
	});
}

function driveCarLights(sprite:FunkinSprite) {
	carInterruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.playAnim('car' + variant);
	var extraOffset = [0, 0];
	var duration:Float = 2;

	switch (variant) {
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.9, 1.5);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	var rotations:Array<Int> = [-7, -5];
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);

	var path:Array<FlxPoint> = [
		FlxPoint.get(1500 - offset[0] - 20, 1049 - offset[1] - 20),
		FlxPoint.get(1770 - offset[0] - 80, 994 - offset[1] + 10),
		FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15)
	];
	
	FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut});
	FlxTween.quadPath(sprite, path, duration, true, {
		ease: FlxEase.cubeOut,
		onComplete: () -> {
			carWaiting = true;
			if (lightsStop == false) finishCarLights(phillyCars);
		}
	});
}

function driveCar(sprite:FunkinSprite) {
	carInterruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.playAnim('car' + variant);
	
	var extraOffset = [0, 0];
	var duration:Float = 2;
	
	switch (variant) {
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.6, 1.2);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);
	var rotations:Array<Int> = [-8, 18];
	var path:Array<FlxPoint> = [
		FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 30),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
		FlxPoint.get(3102 - offset[0], 1187 - offset[1] + 40)
	];

	FlxTween.angle(sprite, rotations[0], rotations[1], duration, null);
	FlxTween.quadPath(sprite, path, duration, true, {
		ease: null,
		onComplete: () -> carInterruptable = true
	});
}

function driveCarBack(sprite:FunkinSprite) {
	car2Interruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.playAnim('car' + variant);
	
	var extraOffset = [0, 0];
	var duration:Float = 2;
	
	switch (variant) {
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.6, 1.2);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);
	var rotations:Array<Int> = [18, -8];
	var path:Array<FlxPoint> = [
		FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 60),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 30),
		FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 10)
	];

	FlxTween.angle(sprite, rotations[0], rotations[1], duration, null);
	FlxTween.quadPath(sprite, path, duration, true, {
		ease: null,
		onComplete: () -> car2Interruptable = true
	});
}

function resetStageValues() {
	lastChange = 0;
	changeInterval = 8;
	if (phillyTraffic != null) phillyTraffic.animation.play('togreen');

	lightsStop = false;
}
