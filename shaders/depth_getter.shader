shader_type spatial;
render_mode unshaded, cull_front;

void fragment(){
	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	
	float actual_depth = -pixel_position.z;
	ALBEDO = vec3(actual_depth);
}