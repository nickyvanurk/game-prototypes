shader_type spatial;

uniform float height_scale = 200;
uniform sampler2D height_map;

varying float height;

void vertex() {
	height = texture(height_map, VERTEX.xz / 513.0 + 0.5).x;
	VERTEX.y = (height - 0.5) * height_scale;
}

void fragment() {
	if (height < 0.4) {
		ALBEDO = vec3(0, 0, 0.5);
	} else if (height < 0.5) {
		ALBEDO = vec3(25.0/255.0, 25.0/255.0, 150.0/255.0);
	} else if (height < 0.55) {
		ALBEDO = vec3(240.0/255.0, 240.0/255.0, 64.0/255.0);
	} else if (height < 0.6) {
		ALBEDO = vec3(50.0/255.0, 220.0/255.0, 20.0/255.0);
	} else if (height < 0.7) {
		ALBEDO = vec3(16.0/255.0, 160.0/255.0, 0);
	} else if (height < 0.75) {
		ALBEDO = vec3(0.5, 0.5, 0.5);
	} else {
		ALBEDO = vec3(1, 1, 1);
	}
}