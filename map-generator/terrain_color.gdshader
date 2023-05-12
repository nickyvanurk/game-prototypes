shader_type spatial;

uniform sampler2D terrain_color;
uniform float min_height = 0;
uniform float max_height = 1;
varying float height;

float inverse_lerp(float a, float b, float value) {
	return clamp(0.01, 1.0, (value - a) / (b - a));
}

void vertex() {
	height = VERTEX.y;
}

void fragment() {
	float position = inverse_lerp(min_height, max_height, height);
	ALBEDO = texture(terrain_color, vec2(position, 0)).rgb;
}