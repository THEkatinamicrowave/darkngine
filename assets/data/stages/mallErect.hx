//
var colorShader:FunkinShader;

function postCreate() {
	colorShader = FunkinShader.fromFile(Paths.fragShader('adjustColor'));
	colorShader.hue = 5;
	colorShader.saturation = 20;

	santa.shader = colorShader;
	for (c in [dad, bf, gf]) if (c != null) {
		c.shader = colorShader;
		c.useRenderTexture = true;
	}

	var colorShaderBoppers:FunkinShader = FunkinShader.fromFile(Paths.fragShader('adjustColor'));
	colorShaderBoppers.hue = 15;
	colorShaderBoppers.brightness = 20;
	bottomBoppers.shader = colorShaderBoppers;
}
