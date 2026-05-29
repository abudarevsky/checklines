shader_type canvas_item;

uniform vec4 cloud_color : source_color = vec4(0.1, 0.22, 0.34, 0.9);

float ellipse(vec2 point, vec2 center, vec2 radius) {
	vec2 p = (point - center) / radius;
	float d = dot(p, p);
	return 1.0 - smoothstep(0.72, 1.0, d);
}

void fragment() {
	vec2 uv = UV;
	float pulse = sin(TIME * 2.1 + uv.x * 8.0) * 0.018;
	float breathe = sin(TIME * 1.35) * 0.035;
	float cloud = 0.0;
	cloud = max(cloud, ellipse(uv, vec2(0.13, 0.56 + pulse), vec2(0.24 + breathe, 0.34)));
	cloud = max(cloud, ellipse(uv, vec2(0.28, 0.41 - pulse), vec2(0.27, 0.39 + breathe)));
	cloud = max(cloud, ellipse(uv, vec2(0.46, 0.53 + pulse), vec2(0.31 + breathe, 0.44)));
	cloud = max(cloud, ellipse(uv, vec2(0.63, 0.40 - pulse), vec2(0.3, 0.4 + breathe)));
	cloud = max(cloud, ellipse(uv, vec2(0.78, 0.53 + pulse), vec2(0.25 + breathe, 0.35)));
	cloud = max(cloud, ellipse(uv, vec2(0.9, 0.58 - pulse), vec2(0.18, 0.28)));

	float soft_body = ellipse(uv, vec2(0.50, 0.56), vec2(0.57, 0.35));
	float dense_core = ellipse(uv, vec2(0.53, 0.55), vec2(0.45, 0.24));
	cloud = max(cloud, soft_body * 0.95);

	float wisps = sin((uv.x + TIME * 0.55) * 34.0) * sin((uv.y - TIME * 0.25) * 18.0);
	float fog = clamp(cloud * 1.08 + dense_core * 0.42 + wisps * 0.05 * cloud, 0.0, 1.0);
	float alpha = fog * cloud_color.a;
	vec3 fog_color = mix(cloud_color.rgb, vec3(0.86, 0.9, 0.92), dense_core * 0.18);
	COLOR = vec4(fog_color, alpha);
}
