shader_type canvas_item;

uniform vec4 beam_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 0.35, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform float time_scale = 1.0;

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float radius = length(centered) * 2.0;
	float angle = atan(centered.y, centered.x);
	float spin = TIME * 4.2 * time_scale + progress * 9.0;
	float spiral = sin(angle * 4.0 + radius * 17.0 - spin);
	float counter = sin(angle * -3.0 + radius * 11.0 + spin * 0.72);
	float beam_band = max(smoothstep(0.56, 0.96, spiral), smoothstep(0.62, 0.98, counter) * 0.7);
	float ring_center = mix(0.22, 0.92, progress);
	float ring = 1.0 - smoothstep(0.0, 0.32, abs(radius - ring_center));
	float edge_fade = 1.0 - smoothstep(0.86, 1.08, radius);
	float center_cut = smoothstep(0.07, 0.24, radius);
	float pulse = 0.72 + 0.28 * sin(TIME * 12.0 + progress * 8.0);
	float fade = 1.0 - smoothstep(0.9, 1.0, progress);
	float intensity = beam_band * ring * edge_fade * center_cut * pulse * fade * alpha * 1.65;
	vec3 color = mix(beam_color.rgb, core_color.rgb, ring * 0.48 + beam_band * 0.18);
	COLOR = vec4(color, intensity);
}
