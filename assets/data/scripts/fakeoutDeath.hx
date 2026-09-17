//
function postCreate() {
	var fakeoutChance:Bool = FlxG.random.bool((1 / 4096) * 100);
	var fakeoutDeathSound:FlxSound = FlxG.sound.load(Paths.sound("gameover/fakeout_death"));
	
	if (!PlayState.chartingMode && fakeoutChance) {
		shouldntExit = true;
		lossSFX.volume = 0; lossSFX.pitch = -0.1;
		
		fakeoutDeathSound.play();
		
		character.playAnim('fakeoutDeath', true);
		character.animation.onFinish.addOnce(() -> {
			shouldntExit = false;
			character.playAnim('firstDeath', true);
			
			lossSFX.volume = lossSFX.pitch = 1;
			lossSFX.play(true);
		});
	}
}
