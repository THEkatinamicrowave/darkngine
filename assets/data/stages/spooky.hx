//
public var lightningStrikeBeat:Int = 0;
public var lightningOffset:Int = 8;

function postCreate() {
	for (sound in ['thunder_1', 'thunder_2'])
		FlxG.sound.load(Paths.sound(sound));

	halloweenBG.playAnim('idle');
}

public function lightningStrikeShit(playSound:Bool, beat:Int) {
	if (playSound) FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	halloweenBG.playAnim('lightning');

	lightningStrikeBeat = beat;
	lightningOffset = FlxG.random.int(8, 24);

	boyfriend.playAnim('scared', true, "SING"); // SING so that they don't get indefinitely looped
	gf.playAnim('scared', true, "SING");
}

function beatHit(beat:Int) {
    if (PlayState.instance.SONG != null) {
      	if ((beat == 4) && (PlayState.instance.SONG.meta.name.toLowerCase() == "spookeez")) {
        	lightningStrikeShit(false, beat);
      	}
    }

    if (FlxG.random.bool(10) && (beat > (lightningStrikeBeat + lightningOffset))) {
      	lightningStrikeShit(true, beat);
    }
}