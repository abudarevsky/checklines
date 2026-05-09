shader_type canvas_item;

uniform sampler2D banner_texture : source_color;
uniform float wind_strength = 8.0;
uniform float wave_speed = 2.0;
uniform float wave_frequency = 6.0;
uniform float secondary_strength = 2.5;
uniform float secondary_frequency = 14.0;
uniform float edge_flutter_strength = 5.0;

void vertex() {
	float anchor = pow(UV.x, 1.45);
	float left_edge = 1.0 - smoothstep(0.0, 0.32, UV.x);
	float right_edge = smoothstep(0.68, 1.0, UV.x);
	float edge = max(left_edge, right_edge);
	float edge_direction = right_edge - left_edge;
	float vertical_edge = abs(UV.y - 0.5) * 2.0;
	float wave1 = sin(UV.x * wave_frequency + TIME * wave_speed);
	float wave2 = sin(UV.x * secondary_frequency - TIME * wave_speed * 1.7);
	float flutter = sin((UV.x + UV.y * 0.8) * secondary_frequency * 1.65 + TIME * wave_speed * 3.1);
	float counter_flutter = sin((1.0 - UV.x + UV.y * 0.7) * secondary_frequency * 1.5 - TIME * wave_speed * 2.8);
	VERTEX.y += (wave1 * wind_strength + wave2 * secondary_strength) * anchor;
	VERTEX.y += (flutter * right_edge + counter_flutter * left_edge) * edge_flutter_strength * vertical_edge;
	VERTEX.x += (wave1 * 1.8 + wave2 * 0.9) * edge * edge_direction;
}

void fragment() {
	COLOR = texture(banner_texture, UV) * COLOR;
}
