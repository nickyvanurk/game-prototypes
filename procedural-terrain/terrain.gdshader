shader_type spatial;

uniform float height_scale = 0.5;
uniform sampler2D noise;
uniform sampler2D normalmap;
global uniform sampler2D height_map;

varying vec2 tex_position;
varying float height;

void vertex() {
	tex_position = VERTEX.xz / 4.0;
	height = texture(height_map, tex_position).r * height_scale;
	VERTEX.y += height;
}

void fragment() {
	NORMAL_MAP = texture(normalmap, tex_position).rgb;
	
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
