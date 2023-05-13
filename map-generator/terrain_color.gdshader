shader_type spatial;

uniform sampler2D sand;
uniform sampler2D grass;
uniform sampler2D rock;

uniform float min_rock_slope: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float max_grass_slope: hint_range(0.0, 1.0, 0.01) = 0.9;
uniform float min_rockgrass_height = -8;
uniform float max_sand_height = -6;

uniform vec2 uv_scale = vec2(40);

uniform sampler2D terrain_color;
uniform float min_height = 0;
uniform float max_height = 1;

varying float height;
varying float normal_y;

float inverse_lerp(float a, float b, float value) {
	return clamp((value - a) / (b - a), 0.01, 1.0);
}

void vertex() {
	height = VERTEX.y;
	normal_y = NORMAL.y;
}

void fragment() {
	float position = inverse_lerp(min_height, max_height, height);
//	float weight = texture(terrain_color, vec2(position, 0)).r;

	vec3 sand_color = texture(sand, UV * uv_scale).rgb;
	vec3 grass_color = texture(grass, UV * uv_scale).rgb;
	vec3 rock_color = texture(rock, UV * uv_scale).rgb;
	
	float rock_grass_weight = normal_y;
	rock_grass_weight = max(min_rock_slope, rock_grass_weight);
	rock_grass_weight = min(max_grass_slope, rock_grass_weight);
	rock_grass_weight -= min_rock_slope;
	rock_grass_weight /= max_grass_slope - min_rock_slope;
	
	float sand_rockgrass_weight = height;
	sand_rockgrass_weight = max(min_rockgrass_height, sand_rockgrass_weight);
	sand_rockgrass_weight = min(max_sand_height, sand_rockgrass_weight);
	sand_rockgrass_weight -= min_rockgrass_height;
	sand_rockgrass_weight /= max_sand_height - min_rockgrass_height;

	vec3 rockgrass_albedo = mix(rock_color, grass_color, rock_grass_weight);
	ALBEDO = mix(sand_color, rockgrass_albedo, sand_rockgrass_weight);
}