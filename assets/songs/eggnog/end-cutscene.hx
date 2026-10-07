//
var blackScreen:FunkinSprite;

function create() {
	blackScreen = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackScreen.scrollFactor.set();
	blackScreen.zoomFactor = 0;
	add(blackScreen);

	FlxTween.tween(game.camHUD, { alpha: 0.0 }, 1.0, { ease: FlxEase.quadInOut });

	var lightsSfx:FlxSound = FlxG.sound.load(Paths.sound('Lights_Shut_off'));
	lightsSfx.onComplete = close;
	lightsSfx.play();
}
