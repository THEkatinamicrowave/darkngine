#pragma header

uniform float hue;
uniform float contrast;
uniform float saturation;
uniform float brightness;

float PI = 3.141592653589793;

mat3 properHue(float h) {
	float properH = h * (PI / 180.0);

    float c = cos(properH);
    float s = sin(properH);

    float wR = 0.299;
    float wG = 0.587;
    float wB = 0.114;

    return mat3(
		(wR + (1.0 - wR) * c - wR * s), (wG - wG * c - wG * s), (wB - wB * c + (1.0 - wB) * s),
		(wR - wR * c + 0.143 * s), (wG + (1.0 - wG) * c + 0.140 * s), (wB - wB * c - 0.283 * s),
		(wR - wR * c - (1.0 - wR) * s), (wG - wG * c + wG * s), (wB + (1.0 - wB) * c + wB * s)
	);
}

mat3 properSaturation(float s) {
	float properS = s;
	if (properS > 0.0) properS = properS * 3.0;
	properS = 1.0 + (properS / 100.0);

    float lr = 0.2126;
    float lg = 0.7152;
    float lb = 0.0722;

    float inv = 1.0 - properS;

    return mat3(
      	(lr * inv + properS), (lg * inv), (lb * inv),
    	(lr * inv), (lg * inv + properS), (lb * inv),
        (lr * inv), (lg * inv), (lb * inv + properS)
	);
}

float properBrightness(float b) {
	return b / 255.0;
}

float properContrast(float c) {
    float e = 2.718281828459045;

	float newC = c;
    newC = 1.0 + (newC / 100.0);
    if (newC > 1.0) {
		newC = (((0.00852259 * pow(e, 4.76454 * (newC - 1.0))) * 1.01) - 0.0086078159) * 10.0; // yeah I have no clue
		newC += 1.0;
    }

	return newC;
}

vec3 applyHSBCEffect(vec3 color) {
	vec3 bh = (properBrightness(brightness) + color) * properHue(hue);
	vec3 c = (bh - 0.25) * properContrast(contrast) + 0.25;
	vec3 s = c * properSaturation(saturation);

	return s;
}

void main() {
	vec4 color4 = texture2D(bitmap, openfl_TextureCoordv);
	vec3 color3 = (color4.a > 0.0) ? color4.rgb / color4.a : color4.rgb;

	color3 = applyHSBCEffect(color3);

	gl_FragColor = vec4(color3 * color4.a, color4.a);
}
