extends Node3D

var system
var destination := ""
var balls := {}
var labels := {}
var orbit_mats := {}
var course: ImmediateMesh
var moon_tag: Label3D

func setup(solar_system) -> void:
	system = solar_system
	_sun()
	_protractor()
	for index in system.planet_ids.size():
		var id := String(system.planet_ids[index])
		_orbit(id, index)
		_planet(id)
	_ship_marker()
	var course_mi := MeshInstance3D.new()
	course_mi.name = "Course"
	course = ImmediateMesh.new()
	course_mi.mesh = course
	course_mi.material_override = _line_mat(Color(1.0, 0.78, 0.35), 0.95)
	course_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(course_mi)
	refresh()

func _process(delta: float) -> void:
	if system == null:
		return
	system.advance(delta)
	refresh()

func refresh() -> void:
	_place()
	if destination == "":
		_draw_course({})
	else:
		_draw_course(system.plot(destination))
	_highlight()

func _sun() -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	var mi := MeshInstance3D.new()
	mi.name = "Sun"
	mi.mesh = mesh
	mi.material_override = _glow(Color(1.0, 0.94, 0.75), 2.2)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.9, 0.7)
	light.light_energy = 0.35
	light.omni_range = 1.8
	light.shadow_enabled = false
	add_child(light)

func _protractor() -> void:
	var rim_point: Vector3 = system.to_table(Vector3(32.0, 0.0, 0.0))
	var rim: float = rim_point.x
	var mesh := ImmediateMesh.new()
	var mat := _line_mat(Color(0.65, 0.8, 0.95), 0.28)
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	for i in 65:
		var ang := TAU * float(i) / 64.0
		mesh.surface_add_vertex(Vector3(cos(ang) * rim, 0.003, sin(ang) * rim))
	mesh.surface_end()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	_tick(Vector3(rim + 0.05, 0.02, 0.0), "0°")
	_tick(Vector3(0.0, 0.02, rim + 0.05), "90°")
	_tick(Vector3(-rim - 0.07, 0.02, 0.0), "180°")
	_tick(Vector3(0.0, 0.02, -rim - 0.07), "270°")

func _tick(pos: Vector3, text: String) -> void:
	var label := _label(text, Color(0.75, 0.88, 1.0), 0.0014)
	label.position = pos
	add_child(label)

func _orbit(id: String, index: int) -> void:
	var color: Color = system.body_color(id)
	var mat := _line_mat(color, 0.45)
	orbit_mats[id] = mat
	var mesh := ImmediateMesh.new()
	var bias := 0.004 + float(index) * 0.0012
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	for i in 97:
		var mean := TAU * float(i) / 96.0
		var point: Vector3 = system.to_table(system.orbit_point(id, mean))
		point.y += bias
		mesh.surface_add_vertex(point)
	mesh.surface_end()
	var mi := MeshInstance3D.new()
	mi.name = "Orbit_%s" % id
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

func _planet(id: String) -> void:
	var root := Node3D.new()
	root.name = id
	add_child(root)
	var radius: float = system.marker_radius(id)
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _glow(system.body_color(id), 1.5)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)
	balls[id] = mi
	var label := _label(id, system.body_color(id).lightened(0.35), 0.0016)
	label.position = Vector3(0.06, 0.03, 0.0)
	root.add_child(label)
	labels[id] = label
	if id == "Saturn":
		var ring := CylinderMesh.new()
		ring.top_radius = radius * 1.9
		ring.bottom_radius = radius * 1.9
		ring.height = 0.003
		var ring_mi := MeshInstance3D.new()
		ring_mi.mesh = ring
		ring_mi.material_override = _glow(Color(0.86, 0.78, 0.52, 0.65), 0.6)
		ring_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(ring_mi)
	if id == "Jupiter":
		moon_tag = _label("", Color(0.95, 0.95, 1.0), 0.0016)
		moon_tag.position = Vector3(0.0, 0.09, 0.0)
		moon_tag.visible = false
		root.add_child(moon_tag)

func _ship_marker() -> void:
	var root := Node3D.new()
	root.name = "Avoca"
	add_child(root)
	var mesh := SphereMesh.new()
	mesh.radius = 0.012
	mesh.height = 0.024
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0.0, 0.03, 0.0)
	mi.material_override = _glow(Color(0.55, 0.95, 1.0), 2.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)
	var pin := CylinderMesh.new()
	pin.top_radius = 0.003
	pin.bottom_radius = 0.003
	pin.height = 0.08
	var pin_mi := MeshInstance3D.new()
	pin_mi.mesh = pin
	pin_mi.position = Vector3(0.0, 0.05, 0.0)
	pin_mi.material_override = _glow(Color(0.55, 0.95, 1.0), 1.2)
	pin_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(pin_mi)
	var label := _label("AVOCA", Color(0.7, 0.95, 1.0), 0.0015)
	label.position = Vector3(0.0, 0.12, 0.0)
	root.add_child(label)

func _place() -> void:
	for id in system.planet_ids:
		var body_id := String(id)
		var node := get_node(body_id) as Node3D
		node.position = system.to_table(system.body_position(body_id, system.day))
	var avoca := get_node("Avoca") as Node3D
	avoca.position = system.to_table(system.ship_position(system.day))

func _draw_course(course_plot: Dictionary) -> void:
	course.clear_surfaces()
	if course_plot.is_empty() or not bool(course_plot.get("solvable", false)):
		return
	var origin: Vector3 = course_plot["origin"]
	var arrive: Vector3 = course_plot["arrive_pos"]
	var mat := _line_mat(Color(1.0, 0.78, 0.35), 0.95)
	course.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	for i in 25:
		var t := float(i) / 24.0
		var sample: Vector3 = system.to_table(origin.lerp(arrive, t))
		sample.y += 0.012
		course.surface_add_vertex(sample)
	course.surface_end()

func _highlight() -> void:
	var focus := destination
	if destination != "" and system.is_moon(destination):
		focus = "Jupiter"
	for id in system.planet_ids:
		var body_id := String(id)
		var hot := body_id == focus and destination != ""
		var ball: MeshInstance3D = balls[body_id]
		ball.scale = Vector3.ONE * (1.55 if hot else 1.0)
		var mat: StandardMaterial3D = orbit_mats[body_id]
		var tint: Color = system.body_color(body_id)
		tint.a = 0.95 if hot else 0.32
		mat.albedo_color = tint
		var label: Label3D = labels[body_id]
		label.modulate = Color(1, 1, 1, 1.0 if hot or destination == "" else 0.45)
	if moon_tag != null:
		var show_moon: bool = destination != "" and bool(system.is_moon(destination))
		moon_tag.visible = show_moon
		if show_moon:
			moon_tag.text = destination

func _label(text: String, color: Color, pixel: float) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = 40
	label.pixel_size = pixel
	label.modulate = color
	label.outline_size = 6
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return label

func _glow(color: Color, energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = Color(color.r, color.g, color.b)
	mat.emission_energy_multiplier = energy
	mat.roughness = 0.35
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat

func _line_mat(color: Color, alpha: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color.r, color.g, color.b, alpha)
	mat.emission_enabled = true
	mat.emission = Color(color.r, color.g, color.b)
	mat.emission_energy_multiplier = 0.7
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat
