//
var normalChar:Character;

function postCreate() {
	if (PlayState.instance != null) {
		normalChar = new Character(0, 0, 'bf', isPlayer);
		normalChar.alpha = 0;

		PlayState.instance.stage.applyCharStuff(normalChar, "boyfriend", 0); // temporarily just locking this to the player position
		PlayState.instance.insert(PlayState.instance.members.indexOf(this), normalChar);
	}

	useRenderTexture = true;
}

function postUpdate(elapsed:Float) {
	if (normalChar != null) {
		normalChar.alpha = (alpha == 1) ? 0 : 1;
	}
}

function onPlayAnim(e:PlayAnimEvent) {
	if (normalChar != null) {
		normalChar.playAnim(e.animName, e.force, e.context, e.reversed, e.startingFrame);
	}
}
