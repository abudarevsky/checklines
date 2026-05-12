shader_type canvas_item;

uniform vec4 effect_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float progress = 0.0;

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float radius = length(centered) * 2.0;
	float angle = atan(centered.y, centered.x);
	float spiral = sin(angle * 3.0 + radius * 16.0 - progress * 11.0);
	float secondary = sin(angle * -2.0 + radius * 10.0 + progress * 8.0);
	float band = max(smoothstep(0.5, 0.92, spiral), smoothstep(0.58, 0.96, secondary) * 0.72);
	float ring_center = mix(0.18, 0.92, progress);
	float ring = 1.0 - smoothstep(0.0, 0.38, abs(radius - ring_center));
	float edge_fade = 1.0 - smoothstep(0.88, 1.08, radius);
	float center_cut = smoothstep(0.08, 0.26, radius);
	float fade = 1.0 - smoothstep(0.88, 1.0, progress);
	float alpha = band * ring * edge_fade * center_cut * fade * effect_color.a * 1.45;
	COLOR = vec4(effect_color.rgb, alpha);
}
