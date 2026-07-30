#pragma header

uniform vec4 uCameraBounds;
uniform float uScale;
uniform float uIntensity;
uniform float uTime;
uniform bool uSpriteMode;
uniform vec3 uRainColor;

vec2 screenToFrame(vec2 screenCoord) {
	vec4 uFrameBounds = vec4(0, 0, 1280, 720);

	float left = uFrameBounds.x;
	float top = uFrameBounds.y;
	float right = uFrameBounds.z;
	float bottom = uFrameBounds.w;
	float width = right - left;
	float height = bottom - top;

	float clampedX = clamp(screenCoord.x, left, right);
	float clampedY = clamp(screenCoord.y, top, bottom);

	return vec2(
		(clampedX - left) / (width),
		(clampedY - top) / (height)
	);
}

vec2 screenToWorld(vec2 screenCoord) {
	float left = uCameraBounds.x;
	float top = uCameraBounds.y;
	float right = uCameraBounds.z;
	float bottom = uCameraBounds.w;

	vec2 scale = vec2(right - left, bottom - top);
	vec2 offset = vec2(left, top);

	return screenCoord * scale + offset;
}

vec2 worldToScreen(vec2 worldCoord) {
	float left = uCameraBounds.x;
	float top = uCameraBounds.y;
	float right = uCameraBounds.z;
	float bottom = uCameraBounds.w;

	vec2 scale = vec2(right - left, bottom - top);
	vec2 offset = vec2(left, top);

	return (worldCoord - offset) / scale;
}

float rand(vec2 a) {
	return fract(sin(dot(mod(a, vec2(1000.0)).xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float rainDist(vec2 p, float scale, float intensity) {
	p *= 0.1;
	p.x += p.y * 0.1;
	p.y -= uTime * 500.0 / scale;
	p.y *= 0.03;
	float ix = floor(p.x);
	
	p.y += mod(ix, 2.0) * 0.5 + (rand(vec2(ix)) - 0.5) * 0.3;
	float iy = floor(p.y);
	vec2 index = vec2(ix, iy);
	
	p -= index;
	p.x += (rand(index.yx) * 2.0 - 1.0) * 0.35;
	
	vec2 a = abs(p - 0.5);
	float res = max(a.x * 0.8, a.y * 0.5) - 0.1;
	
	bool empty = rand(index) < mix(1.0, 0.1, intensity);
	return empty ? 1.0 : res;
}

void main() {
	vec2 wpos = screenToWorld(openfl_TextureCoordv);
	if (uSpriteMode) wpos = screenToWorld(screenToFrame(openfl_TextureCoordv));
	
	vec2 origWpos = wpos;
	float intensity = uIntensity;

	vec3 add = vec3(0);
	float rainSum = 0.0;

	const int numLayers = 4;
	float scales[4];
	scales[0] = 1.0;
	scales[1] = 1.8;
	scales[2] = 2.6;
	scales[3] = 4.8;

	for (int i = 0; i < numLayers; i++) {
		float scale = scales[i];
		float r = rainDist(wpos * scale / uScale + 500.0 * float(i), scale, intensity);
		if (r < 0.0) {
			float v = (1.0 - exp(r * 5.0)) / scale * 2.0;
			wpos.x += v * 10.0 * uScale;
			wpos.y -= v * 2.0 * uScale;
			add += vec3(0.1, 0.15, 0.2) * v;
			rainSum += (1.0 - rainSum) * 0.75;
		}
	}

	vec4 sampleBitmapWorld = texture2D(bitmap, openfl_TextureCoordv);
	vec3 color = sampleBitmapWorld.xyz;
	float alpha = sampleBitmapWorld.w;
	
	if (uSpriteMode) {
		vec2 rwpos = worldToScreen(wpos - origWpos);
		color = flixel_texture2D(bitmap, openfl_TextureCoordv + rwpos).xyz;
		alpha = flixel_texture2D(bitmap, openfl_TextureCoordv + rwpos).w;
	}

	color += add;
	color = mix(color, uRainColor, 0.1 * rainSum);

	gl_FragColor = vec4(color, alpha);
}
