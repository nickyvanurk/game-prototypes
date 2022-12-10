shader_type spatial;
render_mode specular_toon;

uniform sampler2D noise;

float wave(vec2 position) {
	position += texture(noise, position).x;
 	vec2 wv = 1.0 - abs(sin(position));
 	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 position, float time) {
	float d = wave((position + time) * 0.3) * 0.3;
	d += wave((position - time) * 0.4) * 0.3;
	d += wave((position + time) * 0.5) * 0.2;
	d += wave((position - time) * 0.6) * 0.2;
	return d;
}

void vertex() {
	float time = TIME / 100.0;
	vec2 pos = VERTEX.xz;
	float k = height(pos, time);
	VERTEX.y += k * 0.01;
	NORMAL = normalize(vec3(k * 0.01 - height(pos + vec2(0.1, 0.0), time), 0.1, k * 0.01 - height(pos + vec2(0.0, 0.1), time)));
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
  	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.1, 0.3, 0.5) + (0.1 * fresnel);
}