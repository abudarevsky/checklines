shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.82, 0.82, 0.76, 0.74);
uniform vec4 wave_color : source_color = vec4(0.06, 0.07, 0.09, 0.24);
uniform vec4 border_color : source_color = vec4(0.06, 0.055, 0.045, 0.62);
uniform float wave_strength = 0.14;
uniform float wave_speed = 0.32;
uniform float wave_frequency = 6.5;

void fragment() {
	vec2 uv = UV;
	float slow_time = TIME * wave_speed;
	float diagonal = sin((uv.x + uv.y) * wave_frequency + slow_time);
	float cross = sin((uv.x - uv.y) * (wave_frequency * 0.72) - slow_time * 0.83);
	float radial = sin(distance(uv, vec2(0.5)) * wave_frequency * 2.2 - slow_time * 0.65);
	float wave = (diagonal * 0.45 + cross * 0.3 + radial * 0.25) * 0.5 + 0.5;
	float soft_wave = smoothstep(0.42, 0.92, wave) * wave_strength;

	float edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	float border = 1.0 - smoothstep(0.0, 0.055, edge);

	vec4 color = base_color;
	color.rgb = mix(color.rgb, wave_color.rgb, soft_wave);
	color.a = max(color.a, wave_color.a * soft_wave);
	color = mix(color, border_color, border * border_color.a);
	COLOR = color;
}
