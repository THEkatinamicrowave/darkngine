//
var fastCarCanDrive:Bool = false;

function postCreate() {
    for (sound in ['carPass0', 'carPass1'])
      	FlxG.sound.load(Paths.sound(sound));

    var sunOverlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/limo/limoOverlay'));
    sunOverlay.setGraphicSize(Std.int(sunOverlay.width * 2));
    sunOverlay.updateHitbox();
	
	var skyOverlay:CustomShader = new CustomShader('overlayBlend');
    skyOverlay.olayPixels = sunOverlay.pixels;
    limoSunset.shader = skyOverlay;

    resetFastCar();
}

function beatHit(beat:Int) {
    if (FlxG.random.bool(10) && fastCarCanDrive)
		fastCarDrive();
}

function resetFastCar() {
    if (fastCar == null) return;

    fastCar.setPosition(-12600, FlxG.random.int(140, 250));
    fastCar.velocity.x = 0;
    fastCar.active = true;

    fastCarCanDrive = true;
}

function fastCarDrive() {
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;

	new FlxTimer().start(2, resetFastCar);
}
