//
var badVignette:CustomShader;

function postCreate() {
	if (!Options.gameplayShaders) {
		disableScript();
		return;
	}

	badVignette = new CustomShader('coloredVignette');
	badVignette.color = [1.0, 0.0, 0.0];
	camGame.addShader(badVignette);
}

var adder:Int = 0;
function postUpdate(elapsed:Float) {
	var toAdd:Int = lerp(adder, 0, elapsed);
	badVignette.amount = camGame.zoom * camHUD.zoom + toAdd;
	badVignette.strength = (camGame.zoom - camHUD.zoom + toAdd) * 5;
	
	if (adder > 0) adder -= (0.0001 * camZoomingStrength);
}

function beatHit(beat:Int) {
	if (Options.camZoomOnBeat && camZooming && FlxG.camera.zoom < maxCamZoom && curBeat % camZoomingInterval == 0)
		adder = 0.05 * camZoomingStrength;
}