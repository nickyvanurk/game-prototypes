shader_type spatial;

uniform float height_scale = 0.5;
uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_position;
varying float height;

void vertex() {
	tex_position = VERTEX.xz / 2.0 + 0.5;
	height = texture(noise, tex_position).r * height_scale;
	VERTEX.y += height;
}

void fragment() {
	NORMAL_MAP = texture(noise, tex_position).rgb;
	
	if (height < 0.2) {
		ALBEDO = vec3(0.1, 0.3, 0.5);
	} else if (height < 0.25) {
		ALBEDO = vec3(238.0/255.0, 222.0/255.0, 61.0/255.0);
	} else if (height < 0.35) {
		ALBEDO = vec3(79.0/255.0, 187.0/255.0, 40.0/255.0);
	} else {
		ALBEDO = vec3(1, 1, 1);
	}
}
