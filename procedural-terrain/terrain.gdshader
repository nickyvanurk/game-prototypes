shader_type spatial;

uniform float height_scale = 80;

global uniform sampler2D height_map;
global uniform vec2 height_map_size;

varying float height;

void vertex() {
	vec2 texel_size = vec2(1.0 / height_map_size.x, 1.0 / height_map_size.y);
	vec2 tex_position = vec2(VERTEX.x / height_map_size.x + 0.5, VERTEX.z / height_map_size.y + 0.5);
	height = texture(height_map, tex_position).r * height_scale;
	VERTEX.y += height;
	
	float l = texture(height_map, vec2(tex_position.x - texel_size.x, tex_position.y)).r;
	float r = texture(height_map, vec2(tex_position.x + texel_size.x, tex_position.y)).r;
	float t = texture(height_map, vec2(tex_position.x, tex_position.y - texel_size.y)).r;
	float b = texture(height_map, vec2(tex_position.x, tex_position.y + texel_size.y)).r;
	NORMAL = normalize(vec3((l - r)/(2.0*texel_size.x), (t - b)/(2.0*texel_size.y), 1));
}

void fragment() {
	if (height < 41.0) {
		ALBEDO = vec3(238.0/255.0, 222.0/255.0, 61.0/255.0);
	} else if (height < 50.0) {
		ALBEDO = vec3(79.0/255.0, 187.0/255.0, 40.0/255.0);
	} else if (height < 70.0) {
		ALBEDO = vec3(79.0/255.0, 187.0/255.0, 80.0/255.0);
	} else {
		ALBEDO = vec3(1, 1, 1);
	}
}
