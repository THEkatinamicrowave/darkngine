//
import flixel.addons.display.FlxTiledSprite;
import funkin.util.MathUtil;

var rainShader:CustomShader;
var scrollingSky:FlxTiledSprite;

var cameraInitialized:Bool = false;
var cameraDarkened:Bool = false;

var lightningTimer:Float = 3.0;
var lightningActive:Bool = true;

var rainTimeScale:Float = 1.0;

function postCreate() {
    cameraInitialized = false;
    cameraDarkened = false;
    lightningActive = true;

	rainShader = new CustomShader('rain');
	rainShader.uCameraBounds = [FlxG.camera.viewLeft, FlxG.camera.viewTop, FlxG.camera.viewRight, FlxG.camera.viewBottom];
	rainShader.uScale = FlxG.height / 200;
	rainShader.uIntensity = 0.5;
	rainShader.uTime = 0;
	rainShader.uSpriteMode = false;
	rainShader.uRainColor = [0.4, 0.5, 0.8];
	FlxG.camera.addShader(rainShader);
	
    skyAdditive.blend = "add";
    skyAdditive.visible = false;

    lightning.visible = false;

    foregroundMultiply.blend = "multiply";
    foregroundMultiply.visible = false;

    additionalLighten.blend = "add";
    additionalLighten.visible = false;
	
	scrollingSky = new FlxTiledSprite(Paths.image('stages/streets/streets/phillySkybox'), 4000, 495, true, false);
	scrollingSky.setPosition(-700, -120);
	scrollingSky.scrollFactor.set();

	PlayState.instance.insert(members.indexOf(skyAdditive), scrollingSky);
}

function onGameOver(event:GameOverEvent) {
    FlxG.camera.filters = [];
}

function postUpdate(elapsed:Float) {
    rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
    rainShader.update(elapsed * rainTimeScale);

    rainTimeScale = MathUtil.smoothLerpPrecision(rainTimeScale, 0.02, elapsed, 1.535);

    if (scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 35;

	var gf = PlayState.instance.gf;
    if (!cameraInitialized && gf.getCameraPosition() != null) {
		cameraInitialized = true;
		initializeCamera();

		PlayState.instance.bf.color = 0xFFDEDEDE;
		PlayState.instance.dad.color = 0xFFDEDEDE;
		gf.color = 0xFF888888;
		// gf.abot.color = 0xFF888888;
    }

    if (lightningActive)
      	lightningTimer -= FlxG.elapsed;
    else
      	lightningTimer = 1;

    if (lightningTimer <= 0) {
		applyLightning();
		lightningTimer = FlxG.random.float(7, 15);
    }
}

public function onNoteHit(event:NoteHitEvent)
    rainTimeScale += 0.7;

function applyLightning() {
    var LIGHTNING_FULL_DURATION = 1.5;
    var LIGHTNING_FADE_DURATION = 0.3;

    skyAdditive.visible = true;
    skyAdditive.alpha = 0.7;
    FlxTween.tween(skyAdditive, { alpha: 0 }, LIGHTNING_FULL_DURATION, { onComplete: cleanupLightning });

    foregroundMultiply.visible = true;
    foregroundMultiply.alpha = 0.64;
    FlxTween.tween(foregroundMultiply, { alpha: 0 }, LIGHTNING_FULL_DURATION);

    additionalLighten.visible = true;
    additionalLighten.alpha = 0.3;
    FlxTween.tween(additionalLighten, { alpha: 0 }, LIGHTNING_FADE_DURATION);

    lightning.visible = true;
    lightning.playAnim('strike');
	lightning.x = FlxG.random.bool(65) ? FlxG.random.int(-250, 280) : FlxG.random.int(780, 900);

    FlxTween.color(PlayState.instance.bf, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
    FlxTween.color(PlayState.instance.dad, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
    FlxTween.color(PlayState.instance.gf, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);

    FlxG.sound.load(Paths.soundRandom('Lightning', 1, 3), 1.0).play();
}

public override function onSongEnd() {
    lightningActive = false;
}

function cleanupLightning(tween:FlxTween) {
    skyAdditive.visible = foregroundMultiply.visible = additionalLighten.visible = lightning.visible = false;
}

function initializeCamera() {
    PlayState.instance.camGame.fade(0xFF000000, 1.5, true, null, true);
}
