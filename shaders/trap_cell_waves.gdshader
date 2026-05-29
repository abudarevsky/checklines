shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.82, 0.82, 0.76, 0.74);
uniform vec4 wave_color : source_color = vec4(0.06, 0.07, 0.09, 0.24);
uniform vec4 border_color : source_color = vec4(0.06, 0.055, 0.045, 0.62);
uniform vec4 cell_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 stripe_color : source_color = vec4(0.2, 0.2, 0.2, 0.42);
uniform float wave_strength = 0.14;
uniform float wave_speed = 0.32;
uniform float wave_frequency = 6.5;
uniform float stripe_strength = 0.34;

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

	float stripe_position = abs(fract((uv.x + uv.y) * 7.0) - 0.5);
	float stripe = (1.0 - smoothstep(0.035, 0.09, stripe_position)) * stripe_strength;

	vec4 color = cell_color;
	color.rgb = mix(color.rgb, base_color.rgb, base_color.a * 0.62);
	color.a = max(cell_color.a, base_color.a);
	color.rgb = mix(color.rgb, stripe_color.rgb, stripe * stripe_color.a);
	color.rgb = mix(color.rgb, wave_color.rgb, soft_wave);
	color.a = max(color.a, wave_color.a * soft_wave);
	color = mix(color, border_color, border * border_color.a);
	COLOR = color;
}
