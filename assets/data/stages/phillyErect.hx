//
var lightColors:Array<FlxColor> = [
	0xFFB66F43,
	0xFF329A6D,
	0xFF932C28,
	0xFF2663AC,
	0xFF502D64
];

var lightShader:FunkinShader;
var trainSound:FlxSound;

var colorShader:FunkinShader;

var trainEnabled:Bool = true;
var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;
var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;
var startedMoving:Bool = false;

function postCreate() {
	trainEnabled = true;
    trainSound = FlxG.sound.load(Paths.sound('train_passes'));

	colorShader = FunkinShader.fromFile(Paths.fragShader('adjustColor'));
	colorShader.hue = -26;
	colorShader.saturation = -16;
	colorShader.contrast = 0;
	colorShader.brightness = -5;

	dad.shader = bf.shader = gf.shader = train.shader = colorShader;
	for (char in [dad, bf, gf]) char.useRenderTexture = true;

	lightShader = FunkinShader.fromFile(Paths.fragShader('phillyBuildings'));
	lightShader.alphaShit = 1.0;
	lights.shader = lightShader;
}

function postUpdate(elapsed:Float) {
	var shaderInput:Float = (Conductor.crochet / 1000) * elapsed * 1.5;
    lightShader.alphaShit = lightShader.alphaShit + shaderInput;

    if (trainEnabled && trainMoving) {
      	trainFrameTiming += elapsed;

      	if (trainFrameTiming >= (1 / 24)) {
			updateTrainPos();
			trainFrameTiming = 0;
      	}
    }
}

function beatHit(beat:Int) {
    if (trainEnabled) {
		if (!trainMoving) trainCooldown += 1;

		if (beat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
			trainCooldown = FlxG.random.int(-4, 0);
			trainStart();
		}
    }

    if (beat % 4 == 0) {
      	lightShader.alphaShit = 0;

		curLight = FlxG.random.int(0, colors.length - 1);
		lights.color = colors[curLight];
    }
}

function trainStart() {
	trainMoving = true;
	trainSound.play(true);
}

function updateTrainPos() {
    if (trainSound.time >= 4700) {
		startedMoving = true;
		gf.playAnim('hairBlow');
    }

	if (startedMoving) {
		train.x -= 400;

		if (train.x < -2000 && !trainFinishing) {
			train.x = -1150;
			trainCars -= 1;

			if (trainCars <= 0)
				trainFinishing = true;
		}

		if (train.x < -4000 && trainFinishing)
			trainReset();
	}
}

function trainReset() {
	if (startedMoving)
		gf.playAnim('hairFall');

	train.x = FlxG.width + 200;

	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}
