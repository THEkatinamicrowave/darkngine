import openfl.filters.BitmapFilterShader;

//
// var rainShader:RuntimeRainShader;

var lightningStrikeBeat:Int = 0;
var lightningStrikeOffset:Int = 8;

// var lightningSequence:Sequence;
// var lightningSequenceData:Array<SequenceData>;

function postCreate() {
	// rainShader = new RuntimeRainShader();
    // rainShader.scale = FlxG.height / 200 * 2;
    // rainShader.intensity = 0.4;
    // rainShader.spriteMode = true;

    // bgTrees.shader = rainShader;
    // bgTrees.animation.onFrameChange.add(() -> rainShader.updateFrameInfo(bgTrees.frame));
	
	for (sound in ['thunder_1', 'thunder_2'])
		FlxG.sound.load(Paths.sound(sound));
}

function postUpdate(elapsed:Float) {
	// rainShader.update(elapsed);
}

function beatHit(beat:Int) {
    if (FlxG.random.bool(10) && (beat > lightningStrikeBeat + lightningStrikeOffset)) {
      	lightningStrikeShit(true, beat);
    }
}

public function lightningStrikeShit(playSound:Bool, beat:Int) {
	if (playSound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

	bgLight.alpha = stairsLight.alpha = 1;
	dad.alpha = gf.alpha = bf.alpha = 0; // this breaks if they aren't dark
	
    FlxTween.tween(bgLight, { alpha: 0 }, 1.5);
    FlxTween.tween(stairsLight, { alpha: 0 }, 1.5);

    if (bf != null) FlxTween.tween(bf, { alpha: 1 }, 1.5);
    if (dad != null) FlxTween.tween(dad, { alpha: 1 }, 1.5);
    if (gf != null) FlxTween.tween(gf, { alpha: 1 }, 1.5);

	lightningStrikeBeat = Std.parseInt(beat);
	lightningStrikeOffset = Std.parseInt(FlxG.random.int(8, 24));

	if (bf.getAnimName() != 'cheer') bf.playAnim('scared', true, "SING"); // SING so that they don't get indefinitely looped
	gf.playAnim('scared', true, "SING");
}
