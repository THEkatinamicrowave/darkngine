//
import flixel.addons.display.FlxBackdrop;

var colorShader:FunkinShader;

var mist1:FlxBackdrop;
var mist2:FlxBackdrop;
var mist3:FlxBackdrop;
var mist4:FlxBackdrop;
var mist5:FlxBackdrop;

var _timer:Float = 0;
var shootingStarBeat:Int = 0;
var shootingStarOffset:Int = 2;

var fastCarCanDrive:Bool = false;

function postCreate() {
    for (sound in ['carPass0', 'carPass1'])
      	FlxG.sound.load(Paths.sound(sound));

	var sunOverlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('stages/limo/limoOverlay'));
    sunOverlay.setGraphicSize(Std.int(sunOverlay.width * 2));
    sunOverlay.updateHitbox();
	
	var skyOverlay:FunkinShader = FunkinShader.fromFile(Paths.fragShader('overlayBlend'));
    skyOverlay.olayPixels = sunOverlay.pixels;
	
    colorShader = FunkinShader.fromFile(Paths.fragShader('adjustColor'));
    colorShader.hue = -30;
    colorShader.saturation = -20;
    colorShader.contrast = 0;
    colorShader.brightness = -30;

    limoDancer1.shader = colorShader;
    limoDancer2.shader = colorShader;
    limoDancer3.shader = colorShader;
    limoDancer4.shader = colorShader;
    limoDancer5.shader = colorShader;
    fastCar.shader = colorShader;

	for (c in [dad, bf, gf]) {
		if (c == null) continue;

		c.shader = colorShader;
		c.useRenderTexture = true;
	}

    mist1 = new FlxBackdrop(Paths.image('stages/limo/erect/mistMid'), 0x01);
    mist1.setPosition(-650, -100);
    mist1.scrollFactor.set(1.1, 1.1);
    mist1.blend = "add";
    mist1.color = 0xFFc6bfde;
    mist1.alpha = 0.4;
    mist1.velocity.x = 1700;
	PlayState.instance.insert(PlayState.instance.members.indexOf(fastCar), mist1);

    mist2 = new FlxBackdrop(Paths.image('stages/limo/erect/mistBack'), 0x01);
    mist2.setPosition(-650, -100);
    mist2.scrollFactor.set(1.2, 1.2);
    mist2.blend = "add";
    mist2.color = 0xFF6a4da1;
    mist2.alpha = 1;
    mist2.velocity.x = 2100;
    mist1.scale.set(1.3, 1.3);
	PlayState.instance.insert(PlayState.instance.members.indexOf(fastCar), mist2);

    mist3 = new FlxBackdrop(Paths.image('stages/limo/erect/mistMid'), 0x01);
    mist3.setPosition(-650, -100);
    mist3.scrollFactor.set(0.8, 0.8);
    mist3.blend = "add";
    mist3.color = 0xFFa7d9be;
    mist3.alpha = 0.5;
    mist3.velocity.x = 900;
    mist3.scale.set(1.5, 1.5);
	PlayState.instance.insert(PlayState.instance.members.indexOf(gf), mist3);

    mist4 = new FlxBackdrop(Paths.image('stages/limo/erect/mistBack'), 0x01);
    mist4.setPosition(-650, -380);
    mist4.scrollFactor.set(0.6, 0.6);
    mist4.blend = "add";
    mist4.color = 0xFF9c77c7;
    mist4.alpha = 1;
    mist4.velocity.x = 700;
    mist4.scale.set(1.5, 1.5);
	PlayState.instance.insert(PlayState.instance.members.indexOf(gf), mist4);

    mist5 = new FlxBackdrop(Paths.image('limo/erect/mistMid'), 0x01);
    mist5.setPosition(-650, -400);
    mist5.scrollFactor.set(0.2, 0.2);
    mist5.blend = "add";
    mist5.color = 0xFFE7A480;
    mist5.alpha = 1;
    mist5.velocity.x = 100;
    mist5.scale.set(1.5, 1.5);
	PlayState.instance.insert(PlayState.instance.members.indexOf(shootingStar), mist5);
    
    shootingStar.blend = "add";

    resetFastCar();
}

function postUpdate(elapsed:Float) {
    _timer += elapsed;

    mist1.y = 100 + (Math.sin(_timer) * 200);
    mist2.y = 0 + (Math.sin(_timer * 0.8) * 100);
    mist3.y = -20 + (Math.sin(_timer * 0.5) * 200);
    mist4.y = -180 + (Math.sin(_timer * 0.4) * 300);
    mist5.y = -450 + (Math.sin(_timer * 0.2) * 150);
}

function doShootingStar(beat:Int) {
    shootingStar.x = FlxG.random.int(50, 900);
    shootingStar.y = FlxG.random.int(-10, 20);
    shootingStar.flipX = FlxG.random.bool(50);
    shootingStar.playAnim('shooting star');

    shootingStarBeat = beat;
    shootingStarOffset = FlxG.random.int(4, 8);
}

function beatHit(beat:Int) {
    if (FlxG.random.bool(10) && fastCarCanDrive)
		fastCarDrive();

    if (FlxG.random.bool(10) && beat > shootingStarBeat + shootingStarOffset)
    	doShootingStar(beat);
}

function resetFastCar() {
    if (fastCar == null) return;

    fastCar.setPosition(-12600, FlxG.random.int(350, 380));
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
