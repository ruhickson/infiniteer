extends Node3D

func _ready() -> void:
	_layer(1400, 42.0, 78.0, 2.0, Color(1, 1, 1))
	_layer(700, 55.0, 95.0, 3.2, Color(0.72, 0.84, 1.0))
	_layer(280, 60.0, 100.0, 4.4, Color(1.0, 0.86, 0.68))
	var planet := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 5.5
	sphere.height = 11.0
	planet.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.78, 0.62, 0.46)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	planet.material_override = mat
	planet.position = Vector3(28, 16, 42)
	add_child(planet)

func _process(delta: float) -> void:
	rotate_y(delta * 0.012)

func _layer(count: int, min_r: float, max_r: float, point_size: float, color: Color) -> void:
	var verts := PackedVector3Array()
	verts.resize(count)
	for i in count:
		var radius := randf_range(min_r, max_r)
		var theta := randf() * TAU
		var phi := acos(randf_range(-1.0, 1.0))
		verts[i] = Vector3(
			radius * sin(phi) * cos(theta),
			radius * sin(phi) * sin(theta),
			radius * cos(phi)
		)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arrays)
	var shader := Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, fog_disabled, cull_disabled;\nuniform vec4 star_color : source_color = vec4(1.0);\nuniform float point_size = 2.0;\nvoid vertex() { POINT_SIZE = point_size; }\nvoid fragment() { ALBEDO = star_color.rgb; }"
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("star_color", color)
	mat.set_shader_parameter("point_size", point_size)
	var points := MeshInstance3D.new()
	points.mesh = mesh
	points.material_override = mat
	add_child(points)
