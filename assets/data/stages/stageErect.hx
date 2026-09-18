//
var colorShaderBf:FunkinShader;
var colorShaderDad:FunkinShader;
var colorShaderGf:FunkinShader;

function postCreate() {
	colorShaderBf = FunkinShader.fromFile(Paths.fragShader('adjustColor'));
	colorShaderDad = FunkinShader.fromFile(Paths.fragShader('adjustColor'));
	colorShaderGf = FunkinShader.fromFile(Paths.fragShader('adjustColor'));

    colorShaderBf.brightness = -23;
    colorShaderBf.hue = 12;
    colorShaderBf.contrast = 7;
    colorShaderBf.saturation = 0;

    colorShaderGf.brightness = -30;
    colorShaderGf.hue = -9;
    colorShaderGf.contrast = -4;
    colorShaderGf.saturation = 0;

    colorShaderDad.brightness = -33;
    colorShaderDad.hue = -32;
    colorShaderDad.contrast = -23;
    colorShaderDad.saturation = 0;

	brightLightSmall.blend = orangeLight.blend = lightgreen.blend = lightred.blend = lightAbove.blend = "add";

	for (sl in PlayState.instance.strumLines.members) for (c in sl.characters) {
		switch (sl.data.type) {
			case 0: // dad
				c.shader = colorShaderDad;
			case 1: // bf
				c.shader = colorShaderBf;
			case 2: // gf
				c.shader = colorShaderGf;
		}

		c.useRenderTexture = true;
	}
}
