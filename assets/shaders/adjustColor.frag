#pragma header

// this shader is a slighly edited recreation of the Animate/Flash "Adjust Color" filter,
// which was kindly provided and written by Rozebud https://github.com/ThatRozebudDude ( thank u rozebud :) )
// Adapted from Andrey-Postelzhuks shader found here: https://forum.unity.com/threads/hue-saturation-brightness-contrast-shader.260649/
// Hue rotation stuff is from here: https://www.w3.org/TR/filter-effects/#feColorMatrixElement

uniform float hue;
uniform float saturation;
uniform float brightness;
uniform float contrast;

const vec3 lum_values = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
const float E = 2.718281828459045;

vec3 b(vec3 _color, float _brightness) {
	return _color + (_brightness / 255.0);
}

vec3 h(vec3 _color, float _hue) {
	float angle = radians(_hue);

	mat3 grayMat = mat3(vec3(0.213), vec3(0.715), vec3(0.072));
	mat3 cosMat = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
	mat3 sinMat = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);

	mat3 fullMat = grayMat + (cos(angle) * cosMat) + (sin(angle) * sinMat);
	return fullMat * _color;
}

vec3 c(vec3 _color, float _contrast) {
	_contrast = (1.0 + (_contrast / 100.0));
	
	if (_contrast > 1.0) {
		_contrast = (((0.00852259 * pow(E, 4.76454 * (_contrast - 1.0))) * 1.01) - 0.0086078159) * 10.0; //Just roll with it...
		_contrast += 1.0;
	}
	return clamp((_color - 0.25) * _contrast + 0.25, 0.0, 1.0);
}

vec3 s(vec3 _color, float _saturation) {
	if (_saturation > 0.0) _saturation *= 3.0; 

	_saturation = (1.0 + (_saturation / 100.0));
	vec3 grayscale = vec3(dot(_color, lum_values));

    return clamp(mix(grayscale, _color, _saturation), 0.0, 1.0);
}

vec3 adjustColors(vec3 _color) {
	_color = h(
		b(
			c(
				s(
					_color, saturation
				), contrast
			), brightness
		), hue
	);

	return _color;
}

void main() {
	vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
	vec3 unpremultipliedColor = (textureColor.a > 0.0) ? (textureColor.rgb / textureColor.a) : textureColor.rgb;

	vec3 outColor = adjustColors(unpremultipliedColor);

	gl_FragColor = vec4(outColor * textureColor.a, textureColor.a);
}
