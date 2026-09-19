//
public var lightningStrikeBeat:Int = 0;
public var lightningStrikeOffset:Int = 8;

function postCreate() {
	for (sound in ['thunder_1', 'thunder_2'])
		FlxG.sound.load(Paths.sound(sound));

	halloweenBG.playAnim('idle');
}

function beatHit(beat:Int) {
    if (FlxG.random.bool(10) && (beat > lightningStrikeBeat + lightningStrikeOffset)) {
      	lightningStrikeShit(true, beat);
    }
}

public function lightningStrikeShit(playSound:Bool, beat:Int) {
	if (playSound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	halloweenBG.playAnim('lightning');

	lightningStrikeBeat = Std.parseInt(beat);
	lightningStrikeOffset = Std.parseInt(FlxG.random.int(8, 24));

	bf.playAnim('scared', true, "SING"); // SING so that they don't get indefinitely looped
	gf.playAnim('scared', true, "SING");
}
