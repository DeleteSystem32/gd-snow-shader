shader_type spatial;


uniform float avg_snow_height = .4;
uniform float min_snow_height = .05;
uniform float max_snow_variance = .2;

uniform float zero_out = .2;
uniform sampler2D snow_height_map;
uniform sampler2D snow_objects;
uniform sampler2D terrain;
uniform float max_terrain_height = 50f;

uniform sampler2D normal_map;


float get_snow_height(vec2 uv){
	float terrain_height = texture(terrain, uv).r;
	float total_height = clamp(
		texture(snow_objects, uv).r,
		terrain_height, terrain_height + avg_snow_height
	);
	float snow_height = total_height - terrain_height;
	
	float snow_variance = texture(snow_height_map, uv).r * 2f - 1f;
	snow_variance *= max_snow_variance * snow_height;
	snow_variance = min(snow_variance, max_snow_variance);
	total_height += snow_variance - zero_out;
	return total_height;
}

vec2 get_e(){
	return vec2(1f, 0f) / vec2(textureSize(snow_objects, 0));
}

vec3 get_normal(vec2 uv){	
	
	vec2 e = get_e();
	
		
	vec3 normal = normalize(
		vec3(
			get_snow_height(uv - e) - get_snow_height(uv + e),
			2f * e.x,
			get_snow_height(uv - e.yx) - get_snow_height(uv + e.yx)
		)
	);
	
	return normal;
}


void vertex(){
	float total_height = get_snow_height(UV);
	VERTEX.y = total_height * float(total_height < max_terrain_height);
	
	vec2 e = get_e();
	
	/*
	vec2 uv_check = UV;
	
	if((uv_check + e).x >= 1f){
		uv_check -= e;
	}
	
	if((uv_check + e.yx).y >= 1f){
		uv_check -= e.yx;
	}
	
	if((uv_check - e).x <= 0f){
		uv_check += e;
	}
	
	if((uv_check - e.yx).y <= 0f){
		uv_check += e.yx;
	}
	*/
	
	NORMAL = get_normal(UV);
	
}