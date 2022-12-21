shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform float height_scale = 200;
uniform float uvx = 0.0;
uniform float uvy = 0.0;

global uniform sampler2D heightmap;

varying float height;

void vertex() {	
	vec2 v = VERTEX.xz;
	v = (v / 2048.0 + 0.5);
	v.x += uvx / 4.0;
	v.y += uvy / 4.0;
	
	height = texture(heightmap, v).r * height_scale;
	VERTEX.y += height;
	
	vec2 texel_size = vec2(1.0 / 512.0, 1.0 / 512.0);
	float l = texture(heightmap, v + vec2(-texel_size.x, 0)).r;
	float r = texture(heightmap, v + vec2(texel_size.x, 0)).r;
	float t = texture(heightmap, v + vec2(0, -texel_size.y)).r;
	float b = texture(heightmap, v + vec2(0, texel_size.y)).r;
	
	float h_n = texture(heightmap, v).r;
	vec3 va = vec3(0, (t - h_n) * height_scale, -1);
	vec3 vb = vec3(1, (r - h_n) * height_scale, 0);
	vec3 vc = vec3(0, (b - h_n) * height_scale, 1);
	vec3 vd = vec3(-1, (l - h_n) * height_scale, 0);
	
	vec3 average_n = (cross(vb, va) + cross(vc, vb) + cross(vd, vc) + cross(va, vd)) / 4.0;
	NORMAL = normalize(average_n);
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