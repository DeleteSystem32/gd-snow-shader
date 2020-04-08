shader_type spatial;
render_mode unshaded, cull_front;


uniform sampler2D accu_texture;


void fragment(){
	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	
	float actual_depth = -pixel_position.z;
	float accu_depth = texture(accu_texture, SCREEN_UV).r;
	
	accu_depth = mix(accu_depth, actual_depth, float(accu_depth <= 0f));
	
	ALBEDO = vec3(min(actual_depth, accu_depth));
}