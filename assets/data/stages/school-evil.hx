//
var wiggleBack:CustomShader;
var wiggleSchool:CustomShader;
var wiggleGround:CustomShader;
var wiggleTrees:CustomShader;

function postCreate() {
	for (stageShit in [backTrees, school, street, trees]) {
		stageShit.antialiasing = false;
		stageShit.scale.set(6, 6);
		stageShit.updateHitbox();
	}

	wiggleBack = new CustomShader('wiggle');
	wiggleBack.uSpeed = 1.6;
	wiggleBack.uFrequency = 1.6;
	wiggleBack.uWaveAmplitude = 0.011;
	wiggleBack.effectType = 0;
	backTrees.shader = wiggleBack;

	wiggleSchool = new CustomShader('wiggle');
	wiggleSchool.uSpeed = 2;
	wiggleSchool.uFrequency = 4;
	wiggleSchool.uWaveAmplitude = 0.017;
	wiggleSchool.effectType = 0;
	school.shader = wiggleSchool;

	wiggleGround = new CustomShader('wiggle');
	wiggleGround.uSpeed = 2;
	wiggleGround.uFrequency = 4;
	wiggleGround.uWaveAmplitude = 0.007;
	wiggleGround.effectType = 0;
	street.shader = wiggleGround;

	wiggleTrees = new CustomShader('wiggle');
	wiggleTrees.uSpeed = 2;
	wiggleTrees.uFrequency = 4;
	wiggleTrees.uWaveAmplitude = 0.007;
	wiggleTrees.effectType = 0;
	trees.shader = wiggleTrees;

	isSpooky = true;
	if (PlayState.smoothTransitionData?.stage == "school")
		PlayState.smoothTransitionData.stage = curStage;
}

function postUpdate(elapsed:Float) {
	wiggleBack.uTime = wiggleBack.uTime + elapsed;
	wiggleSchool.uTime = wiggleBack.uTime + elapsed;
	wiggleGround.uTime = wiggleBack.uTime + elapsed;
	wiggleTrees.uTime = wiggleBack.uTime + elapsed;
}
