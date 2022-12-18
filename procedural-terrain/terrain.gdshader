shader_type spatial;

uniform float height_scale = 200;
uniform float uvx = 0.0;
uniform float uvy = 0.0;

global uniform sampler2D heightmap;
const float heightmap_size = 2048.0;
const float mesh_size = 512.0;
const float scale = 1.0 / (heightmap_size / mesh_size);

varying float height;

void vertex() {
	UV *= scale;
	UV += 0.5 - scale / 2.0;

	UV.x += uvx * scale;
	UV.y += uvy * scale;
	
	height = texture(heightmap, UV).r * height_scale;
	VERTEX.y += height;
	
	vec2 texel_size = vec2(1.0 / (heightmap_size * scale), 1.0 / (heightmap_size * scale));
	float l = texture(heightmap, UV + vec2(-texel_size.x, 0)).r;
	float r = texture(heightmap, UV + vec2(texel_size.x, 0)).r;
	float t = texture(heightmap, UV + vec2(0, -texel_size.y)).r;
	float b = texture(heightmap, UV + vec2(0, texel_size.y)).r;
	NORMAL = normalize(vec3((l - r), 2.0*texel_size.x, (t - b)));
}

void fragment() {
	if (height < 40.5) {
		ALBEDO = vec3(238.0/255.0, 222.0/255.0, 61.0/255.0);
	} else if (height < 100.0) {
		ALBEDO = vec3(79.0/255.0, 187.0/255.0, 40.0/255.0);
	} else if (height < 180.0) {
		ALBEDO = vec3(79.0/255.0, 187.0/255.0, 80.0/255.0);
	} else {
		ALBEDO = vec3(1, 1, 1);
	}
}
