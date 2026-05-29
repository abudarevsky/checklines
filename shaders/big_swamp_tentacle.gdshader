shader_type canvas_item;

uniform vec4 swamp_color : source_color = vec4(0.25, 0.45, 0.20, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float alpha = 1.0;

float ring(vec2 uv, float r, float width) {
	float d = distance(uv, vec2(0.5));
	return smoothstep(width, 0.0, abs(d - r));
}

void fragment() {
	vec2 uv = UV;

	float quake = 0.0;
	float freq = mix(3.0, 12.0, progress);

	for (float i = 0.0; i < 5.0; i++) {
		float r = fract(progress * freq - i * 0.18);
		quake += ring(uv, r * 0.65, 0.035);
	}

	float splash_time = smoothstep(0.35, 0.55, progress) * (1.0 - smoothstep(0.65, 0.82, progress));
	float splash = smoothstep(0.32, 0.0, distance(uv, vec2(0.5))) * splash_time;

	vec4 col = swamp_color;
	col.rgb += quake * 0.25;
	col.a = clamp((quake * 0.35 + splash) * alpha, 0.0, 1.0);

	COLOR = col;
}
