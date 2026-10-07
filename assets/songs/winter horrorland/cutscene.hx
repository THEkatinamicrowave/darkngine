//
var blackScreen:FunkinSprite;

function create() {
	game.camHUD.visible = false;

	blackScreen = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackScreen.scrollFactor.set();
	blackScreen.zoomFactor = 0;
	add(blackScreen);

	new FlxTimer().start(0.1, () -> {
		remove(blackScreen);

		game.camFollow.setPosition(400, -2050);
		game.camGame.scroll.set(game.camFollow.x, game.camFollow.y);
		game.camGame.zoom = 2.5;
		FlxTween.tween(game.camGame, { zoom: game.defaultCamZoom }, 2.25, { ease: FlxEase.expoOut });

		var lightsSfx:FlxSound = FlxG.sound.load(Paths.sound('Lights_Turn_On'));
		lightsSfx.onComplete = () -> {
			game.camHUD.visible = true;
			game.camHUD.alpha = 0.0;
			FlxTween.tween(game.camHUD, { alpha: 1.0 }, 2.0, { ease: FlxEase.quadInOut });

			close();
		}
		lightsSfx.play();
	});
}
