//
function postCreate() {
	for (stageShit in [sky, backTrees, school, street, treesFG, treesBG, petals, freaks]) {
		stageShit.antialiasing = false;
		stageShit.scale.set(6, 6);
		stageShit.updateHitbox();
	}

	if (PlayState.SONG.meta.name.toLowerCase() == "roses") {
		freaks.removeAnim("danceLeft");
		freaks.removeAnim("danceRight");
		freaks.addAnim('danceLeft', 'BG fangirls dissuaded', 24, false, false, CoolUtil.numberArray(15));
		freaks.addAnim('danceRight', 'BG fangirls dissuaded', 24, false, false, CoolUtil.numberArray(30, 15));
	}
	freaks.playAnim("danceLeft", true); // horrible fix, please fix later
}