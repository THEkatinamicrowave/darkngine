#pragma header

uniform sampler2D olayPixels;

vec4 blendOverlay(vec4 base, vec4 blend) {
	vec4 mixed = mix(1.0 - 2.0 * (1.0 - base) * (1.0 - blend), 2.0 * base * blend, step(base, vec4(0.5)));

	return mixed;
}

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	vec4 gf = flixel_texture2D(olayPixels, openfl_TextureCoordv.xy + vec2(0.1, 0.2));

    gl_FragColor = blendOverlay(color, gf);
}