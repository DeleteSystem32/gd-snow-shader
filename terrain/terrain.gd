extends StaticBody


export(Vector2) var terrain_size := Vector2(64, 64)

export(OpenSimplexNoise) var gen_noise : OpenSimplexNoise = null
export(float) var max_terrain_height := 20.0

export(Vector2) var terrain_resolution := Vector2(64, 64)
export(Vector2) var snow_vert_per_unit := Vector2(10,10)

func _ready():
	generate()

func generate():
		
	# make sure children of viewports are centered
	$vp_snow_objects/Spatial.transform.origin = transform.origin
	$vp_terrain/Spatial.transform.origin = transform.origin
		
	
	
	var snow_resolution = terrain_resolution * snow_vert_per_unit
	$snow_mesh.mesh.size = terrain_size
	$snow_mesh.mesh.subdivide_depth = snow_resolution.y -1
	$snow_mesh.mesh.subdivide_width = snow_resolution.x -1
	$snow_mesh.set_custom_aabb(AABB(
		Vector3(
			-terrain_size.x /2,
			0,
			-terrain_size.y /2
		), 
		Vector3(
			terrain_size.x,
			max_terrain_height + 1,
			terrain_size.y
		)
	))
	
	$vp_snow_objects.size = snow_resolution
	$vp_terrain.size = snow_resolution
	
	$vp_snow_objects/Spatial/depth_projection.mesh.size = terrain_size
	$vp_snow_objects/Spatial/Camera.size = terrain_size.x
	$vp_terrain/Spatial/depth_projection.mesh.size = terrain_size
	$vp_terrain/Spatial/Camera.size = terrain_size.x
	
	
	var base_mesh = PlaneMesh.new()
	base_mesh.size = terrain_size
	base_mesh.subdivide_depth = terrain_resolution.y - 1
	base_mesh.subdivide_width = terrain_resolution.x -1
	
	var arrays = base_mesh.surface_get_arrays(0)
	var vertex_amount = arrays[Mesh.ARRAY_VERTEX].size()
	for i in range(vertex_amount):
		var vtx = arrays[Mesh.ARRAY_VERTEX][i]
		var vtx2 = Vector2(vtx.x, vtx.z) + Vector2(
			transform.origin.x, transform.origin.z)
			
		arrays[Mesh.ARRAY_VERTEX][i].y = max_terrain_height * (
			(gen_noise.get_noise_2dv(vtx2) +1.0) / 2.0)
			
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	$terrain_mesh.mesh = new_mesh
	$CollisionShape.shape = new_mesh.create_trimesh_shape()
