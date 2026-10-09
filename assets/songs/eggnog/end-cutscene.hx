//
var blackScreen:FunkinSprite;

var santaSound:FlxSound;
var shootSound:FlxSound;

function create() {
	switch (PlayState.variation) {
		default:
			close();
		case null, "":
			blackScreen = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
			blackScreen.scrollFactor.set();
			blackScreen.zoomFactor = 0;
			add(blackScreen);

			FlxTween.tween(game.camHUD, { alpha: 0.0 }, 1.0, { ease: FlxEase.quadInOut });

			var lightsSfx:FlxSound = FlxG.sound.load(Paths.sound('Lights_Shut_off'));
			lightsSfx.onComplete = close;
			lightsSfx.play();
		case "erect":
			game.camGame.snapToTarget();

			var normalSanta = game.stage.stageSprites.get('santa');
			normalSanta.visible = false;

			var santaDead:FunkinSprite = new FunkinSprite(-1300, 100).loadSprite('stages/mall/santa_speaks_assets');
			santaDead.shader = normalSanta.shader;
			game.insert(game.members.indexOf(normalSanta), santaDead);
			santaDead.addAnim('cutscene', 'santa whole scene');
			santaDead.playAnim('cutscene');

			game.dad.visible = false;

			var parentsShoot:FunkinSprite = new FunkinSprite(-602, -3.5).loadSprite('stages/mall/parents_shoot_assets');
			parentsShoot.shader = normalSanta.shader;
			game.insert(game.members.indexOf(santaDead), parentsShoot);
			parentsShoot.addAnim('cutscene', 'parents whole scene');
			parentsShoot.playAnim('cutscene');

			// PlayState.instance.currentStage.getBoyfriend().danceEvery = 0;
			// PlayState.instance.currentStage.getDad().danceEvery = 0;

			FlxTween.tween(game.camFollow, { x: santaDead.x + 1200, y: santaDead.y + 300 }, 2.8, { ease: FlxEase.expoOut });
			FlxTween.tween(game.camGame, { zoom: 0.73 }, 2, { ease: FlxEase.quadInOut });

			santaSound = FlxG.sound.load(Paths.sound('santa_emotion'));
			santaSound.play();

			shootSound = FlxG.sound.load(Paths.sound('santa_shot_n_falls'));

			// nnnngh cutscene stuffaaaaaaaaaaaa
			new FlxTimer().start(2.8, () -> {
				FlxTween.tween(game.camFollow, { x: santaDead.x + 1050, y: santaDead.y + 300 }, 9, { ease: FlxEase.quartInOut });
				FlxTween.tween(game.camGame, { zoom: 0.79 }, 2, { ease: FlxEase.quadInOut });
			});

			new FlxTimer().start(11.375, () -> {
				shootSound.play();
			});

			new FlxTimer().start(12.83, () -> {
				game.camGame.shake(0.005, 0.2);
				FlxTween.tween(game.camFollow, { x: santaDead.x + 1060, y: santaDead.y + 380 }, 5, { ease: FlxEase.expoOut });
			});

			new FlxTimer().start(15, () -> {
				game.camHUD.fade(0xFF000000, 1, false, null, true);
			});

			new FlxTimer().start(16, close);
	}
}
