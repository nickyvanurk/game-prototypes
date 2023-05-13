shader_type spatial;
render_mode world_vertex_coords, depth_draw_always, cull_disabled;

instance uniform float patch_size = 512.0;
instance uniform float min_lod_morph_distance;
instance uniform float max_lod_morph_distance;

uniform float vertex_resolution = 256.0;

vec2 lod_morph(float morph_factor, vec2 grid_pos) {
	vec2 fracPart = fract(grid_pos.xy * vertex_resolution * 0.5) * 2.0 / vertex_resolution;
	return fracPart * (patch_size - 1.0) * morph_factor;
}

void vertex() {
	float linear_dist = length(VERTEX - CAMERA_POSITION_WORLD);
	float morph_factor = (clamp(linear_dist, min_lod_morph_distance, max_lod_morph_distance) - min_lod_morph_distance) / (max_lod_morph_distance - min_lod_morph_distance);
	VERTEX.xz -= lod_morph(morph_factor, UV);
}
