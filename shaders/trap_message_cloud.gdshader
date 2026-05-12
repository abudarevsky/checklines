shader_type canvas_item;

uniform vec4 cloud_color : source_color = vec4(0.1, 0.22, 0.34, 0.9);

float ellipse(vec2 point, vec2 center, vec2 radius) {
	vec2 p = (point - center) / radius;
	float d = dot(p, p);
	return 1.0 - smoothstep(0.72, 1.0, d);
}

void fragment() {
	vec2 uv = UV;
	float pulse = sin(TIME * 2.4 + uv.x * 8.0) * 0.015;
	float cloud = 0.0;
	cloud = max(cloud, ellipse(uv, vec2(0.18, 0.55 + pulse), vec2(0.22, 0.34)));
	cloud = max(cloud, ellipse(uv, vec2(0.34, 0.43 - pulse), vec2(0.25, 0.37)));
	cloud = max(cloud, ellipse(uv, vec2(0.52, 0.50 + pulse), vec2(0.29, 0.42)));
	cloud = max(cloud, ellipse(uv, vec2(0.70, 0.46 - pulse), vec2(0.24, 0.36)));
	cloud = max(cloud, ellipse(uv, vec2(0.84, 0.55 + pulse), vec2(0.20, 0.31)));

	float soft_body = ellipse(uv, vec2(0.50, 0.57), vec2(0.53, 0.31));
	cloud = max(cloud, soft_body * 0.92);

	float wisps = sin((uv.x + TIME * 0.55) * 34.0) * sin((uv.y - TIME * 0.25) * 18.0);
	float alpha = clamp(cloud + wisps * 0.035 * cloud, 0.0, 1.0) * cloud_color.a;
	COLOR = vec4(cloud_color.rgb, alpha);
}
