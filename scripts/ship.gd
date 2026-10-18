extends Node3D

const Config = preload("res://scripts/config.gd")
const SolarSystem = preload("res://scripts/solar_system.gd")
const OrreryScript = preload("res://scripts/orrery.gd")

var collision
var solar
var orrery: Node3D

func setup(collision_world) -> void:
	collision = collision_world
	solar = SolarSystem.new()

func _ready() -> void:
	_build_industrial()
	_build_operations()
	_build_civilian()
	_build_bridge()
	_build_corridor()
	_build_elevator()

func _build_industrial() -> void:
	var y := Config.INDUSTRIAL_FLOOR
	var h := Config.DECK_HEIGHT
	var floor_mat := _panel("#7d6608", "#f7dc6f")
	var wall_mat := _panel("#f4d03f", "#f9e79f")
	_square_deck(y, floor_mat, _flat("#2b3036"), wall_mat, false, false)
	_zone("industrial", "Industrial Deck", -25, y, -25, 25, y + h, 25)
	_room_ew(y, h, wall_mat, -14, 14, -7, -25, "engine", "Engine Room")
	_room_ns(y, h, wall_mat, -7, -25, -7, 6.7, "systems", "Systems")
	_room_ew(y, h, wall_mat, -25, -5, 7, 25, "hold", "Hold")
	_room_ew(y, h, wall_mat, 5, 25, 7, 25, "weapons", "Weapons")
	_room_ns(y, h, wall_mat, 7, 25, -7, 6.7, "emergency", "Emergency")
	_sign("ENGINE ROOM", Vector3(0, y + 1.55, -6.75), PI, Color(1, 0.9, 0.4))
	_sign("SYSTEMS", Vector3(-6.75, y + 1.55, 0), PI * 0.5, Color(1, 0.9, 0.4))
	_sign("HOLD", Vector3(-10, y + 1.55, 6.75), 0, Color(1, 0.9, 0.4))
	_sign("WEAPONS", Vector3(10, y + 1.55, 6.75), 0, Color(1, 0.9, 0.4))
	_sign("EMERGENCY", Vector3(6.75, y + 1.55, 0), -PI * 0.5, Color(1, 0.9, 0.4))
	_engine_core(Vector3(-4.2, y, -13))
	_engine_core(Vector3(4.2, y, -13))
	_engine_core(Vector3(0, y, -16.5))
	_rack(Vector3(-14, y, -2), PI * 0.5, Color(1, 0.85, 0.3))
	_rack(Vector3(-14, y, 2), PI * 0.5, Color(0.55, 0.8, 1))
	for i in 4:
		_crate(Vector3(-14 + (i % 2) * 1.4, y, 10 + int(i / 2) * 1.4), Color("#9a7d0a"))
		_crate(Vector3(8 + (i % 2) * 1.3, y, 10 + int(i / 2) * 1.4), Color("#6e4b1f"))
	_rack(Vector3(9, y, 12), 0, Color(0.75, 0.22, 0.18))
	_console(Vector3(14, y, -2), -PI * 0.5, Color("#d4ac0d"), Color(1, 0.4, 0.35))
	_light(Vector3(0, y + 2.2, -14), Color(1, 0.86, 0.4), 1.6, 12)
	_light(Vector3(-14, y + 2.2, 0), Color(1, 0.9, 0.55), 1.2, 9)
	_light(Vector3(14, y + 2.2, 0), Color(1, 0.8, 0.4), 1.2, 9)
	_light(Vector3(-10, y + 2.2, 12), Color(1, 0.85, 0.45), 1.1, 8)
	_light(Vector3(10, y + 2.2, 12), Color(1, 0.7, 0.35), 1.1, 8)
	_strip(Vector3(0, y + h - 0.06, -12), 6.0, Color(1, 0.9, 0.5))

func _build_operations() -> void:
	var y := Config.OPERATIONS_FLOOR
	var h := Config.DECK_HEIGHT
	var floor_mat := _panel("#1f5270", "#5dade2")
	var wall_mat := _panel("#3498db", "#85c1e9")
	_square_deck(y, floor_mat, _flat("#1b242c"), wall_mat, true, false)
	_zone("operations", "Operations Deck", -25, y, -25, 25, y + h, 25)
	_room_ew(y, h, wall_mat, -16, 16, -7, -25, "communications", "Communications")
	_wall_door(-9, 7, 9, 7, y, h, wall_mat)
	_wall(-9, 7, -9, 18, y, h, wall_mat)
	_wall(9, 7, 9, 18, y, h, wall_mat)
	_wall_door(-9, 18, 9, 18, y, h, wall_mat)
	_zone("navigation", "Navigation", -9, y, 6.2, 9, y + h, 24.5)
	_sign("COMMUNICATIONS", Vector3(0, y + 1.55, -6.75), PI, Color(0.7, 0.9, 1))
	_sign("NAVIGATION", Vector3(0, y + 1.55, 6.75), 0, Color(0.7, 0.9, 1))
	_sign("BRIDGE", Vector3(0, y + 1.55, 17.7), PI, Color(0.85, 0.93, 1))
	for i in 5:
		var x := (i - 2) * 2.3
		_console(Vector3(x, y, -12), 0, Color("#2e86c1"), Color(0.55, 0.85, 1))
		_chair(Vector3(x, y, -10.7), PI, Color("#1a4c72"))
	_add_cyl(Vector3(0, y + 0.18, 12), 0.22, 0.36, _flat("#16384d"), false)
	_add_cyl(Vector3(0, y + 0.45, 12), 1.7, 0.16, _flat("#1a4c72"), true)
	_add_cyl(Vector3(0, y + 0.56, 12), 1.25, 0.05, _emissive(Color(0.45, 0.75, 1), 0.7), false)
	_sign("SYSTEM PLOT", Vector3(0, y + 1.2, 9.55), 0, Color(0.75, 0.9, 1))
	orrery = OrreryScript.new()
	orrery.name = "Orrery"
	orrery.position = Vector3(0, y + 0.70, 12)
	orrery.setup(solar)
	add_child(orrery)
	_console(Vector3(-4.2, y, 13.2), 0.4, Color("#2e86c1"), Color(0.55, 0.85, 1))
	_console(Vector3(4.2, y, 13.2), -0.4, Color("#2e86c1"), Color(0.55, 0.85, 1))
	_light(Vector3(0, y + 2.15, -12), Color(0.65, 0.84, 1), 1.5, 11)
	_light(Vector3(0, y + 2.15, 13), Color(0.55, 0.78, 1), 1.5, 12)
	_light(Vector3(0, y + 2.15, 21), Color(0.75, 0.88, 1), 1.0, 8)

func _build_civilian() -> void:
	var y := Config.CIVILIAN_FLOOR
	var h := Config.DECK_HEIGHT
	var floor_mat := _panel("#245c43", "#58d68d")
	var wall_mat := _panel("#3d8b5f", "#7dcea0")
	_square_deck(y, floor_mat, _glass(Color(0.72, 0.9, 0.8, 0.16)), wall_mat, false, true)
	_zone("civilian", "Civilian Deck", -25, y, -25, 25, y + h + 0.4, 25)
	_quarters(y, h, wall_mat)
	_room_ns(y, h, wall_mat, -7, -25, -6.7, 6.7, "procurement", "Procurement")
	_room_ns(y, h, wall_mat, 7, 25, -6.7, 6.7, "laboratory", "Laboratory")
	_wall_door(-14, 8, 14, 8, y, h, wall_mat)
	_wall(-14, 8, -14, 25, y, h, wall_mat)
	_wall(14, 8, 14, 25, y, h, wall_mat)
	_zone("lounge", "Lounge", -14, y, 7.6, 14, y + h + 0.4, 25)
	_sign("QUARTERS", Vector3(0, y + 1.5, -6.15), PI, Color(0.85, 0.97, 0.9))
	_sign("PROCUREMENT", Vector3(-6.75, y + 1.5, 0), PI * 0.5, Color(0.85, 0.97, 0.9))
	_sign("LABORATORY", Vector3(6.75, y + 1.5, 0), -PI * 0.5, Color(0.85, 0.97, 0.9))
	_sign("LOUNGE", Vector3(0, y + 1.5, 7.75), 0, Color(0.85, 0.97, 0.9))
	for i in 4:
		_crate(Vector3(-16 + (i % 2) * 1.5, y, -2 + int(i / 2) * 1.6), Color("#1b4d39"))
	_rack(Vector3(-16, y, 2), PI * 0.5, Color(0.55, 0.85, 0.65))
	_console(Vector3(-11, y, 0), PI * 0.5, Color("#52be80"), Color(0.8, 1, 0.9))
	_lounge_seat(Vector3(-3.2, y, 11), 0.2)
	_lounge_seat(Vector3(3.2, y, 11), -0.2)
	_lounge_seat(Vector3(0, y, 15), PI)
	_plant(Vector3(-6.5, y, 9))
	_plant(Vector3(6.5, y, 9))
	_plant(Vector3(0, y, 13.2))
	_lab_bench(Vector3(12, y, -2.2), 0)
	_lab_bench(Vector3(16, y, -2.2), 0)
	_lab_bench(Vector3(12, y, 2.2), PI)
	_rack(Vector3(18, y, 0), -PI * 0.5, Color(0.8, 1, 0.9))
	_light(Vector3(0, y + 2.2, -10), Color(0.8, 1, 0.88), 1.3, 10)
	_light(Vector3(-14, y + 2.2, 0), Color(0.7, 0.95, 0.8), 1.2, 9)
	_light(Vector3(14, y + 2.2, 0), Color(0.7, 0.95, 0.8), 1.2, 9)
	_light(Vector3(0, y + 2.2, 12), Color(0.75, 1, 0.85), 1.4, 11)

func _quarters(y: float, h: float, wall_mat: Material) -> void:
	var left := -8.2
	var right := 8.2
	var front := -8.2
	var back := -20.4
	var hall := 0.85
	var mid := -14.2
	_wall(left, front, left, back, y, h, wall_mat)
	_wall(right, front, right, back, y, h, wall_mat)
	_wall(left, back, right, back, y, h, wall_mat)
	_wall(left, front, -hall, front, y, h, wall_mat)
	_wall(hall, front, right, front, y, h, wall_mat)
	_wall_door(-hall, front, hall, front, y, h, wall_mat, 1.15)
	_wall_door(-hall, mid, -hall, front, y, h, wall_mat, 1.05)
	_wall_door(-hall, back, -hall, mid, y, h, wall_mat, 1.05)
	_wall_door(hall, mid, hall, front, y, h, wall_mat, 1.05)
	_wall_door(hall, back, hall, mid, y, h, wall_mat, 1.05)
	_wall(left, mid, -hall, mid, y, h, wall_mat)
	_wall(hall, mid, right, mid, y, h, wall_mat)
	_zone("q1", "Quarters 01", left, y, mid, -hall, y + h, front)
	_zone("q2", "Quarters 02", hall, y, mid, right, y + h, front)
	_zone("q3", "Quarters 03", left, y, back, -hall, y + h, mid)
	_zone("q4", "Quarters 04", hall, y, back, right, y + h, mid)
	_sign("Q-01", Vector3(-4.2, y + 1.35, mid + 0.08), 0, Color(0.8, 0.95, 0.86))
	_sign("Q-02", Vector3(4.2, y + 1.35, mid + 0.08), 0, Color(0.8, 0.95, 0.86))
	_sign("Q-03", Vector3(-4.2, y + 1.35, mid - 0.08), PI, Color(0.8, 0.95, 0.86))
	_sign("Q-04", Vector3(4.2, y + 1.35, mid - 0.08), PI, Color(0.8, 0.95, 0.86))
	_furnish_quarter(-4.5, -11.2, y)
	_furnish_quarter(4.5, -11.2, y)
	_furnish_quarter(-4.5, -17.3, y)
	_furnish_quarter(4.5, -17.3, y)

func _furnish_quarter(cx: float, cz: float, y: float) -> void:
	_bed(Vector3(cx - 1.5, y, cz), PI * 0.5, Color(0.62, 0.9, 0.75))
	_console(Vector3(cx + 1.7, y, cz - 0.6), -PI * 0.5, Color("#3d8b5f"), Color(0.85, 1, 0.92))
	_chair(Vector3(cx + 0.9, y, cz - 0.6), PI * 0.5, Color("#1b4d39"))
	_crate(Vector3(cx + 1.6, y, cz + 1.3), Color("#1b4d39"), 0.55)
	_plant(Vector3(cx - 1.7, y, cz + 1.2))
	_light(Vector3(cx, y + 2.15, cz), Color(0.85, 1, 0.9), 0.7, 5)

func _build_bridge() -> void:
	var y := Config.OPERATIONS_FLOOR
	var h := Config.DECK_HEIGHT
	var cz := Config.BRIDGE_CZ
	var floor_mat := _panel("#273746", "#5d6d7e")
	var wall_mat := _panel("#2c3e50", "#7f8c9b")
	var half := Config.BRIDGE_HALF
	_add_box(Vector3(0, y + 0.04, cz), Vector3(half * 2, 0.08, half * 2), floor_mat, 0, false)
	_add_box(Vector3(0, y + h - 0.04, cz), Vector3(half * 2, 0.06, half * 2), _glass(Color(0.75, 0.88, 1, 0.16)), 0, false)
	collision.add_floor(-half, half, cz - half, cz + half, y, y + h)
	_wall(-half, cz - half, -half, cz + half, y, h, wall_mat, true, true)
	_wall(half, cz - half, half, cz + half, y, h, wall_mat, true, true)
	_wall(-half, cz + half, half, cz + half, y, h, wall_mat, true, true)
	_wall_door(-half, cz - half, half, cz - half, y, h, wall_mat, 1.7, true)
	_zone("bridge", "Bridge", -half, y, cz - half, half, y + h, cz + half)
	var screen_z := cz + half - 0.7
	_add_box(Vector3(0, y + 1.35, screen_z + 0.08), Vector3(8.2, 1.55, 0.12), _flat("#10161c"), 0, true)
	_monitor(Vector3(0, y + 1.35, screen_z), Vector3(7.8, 1.4, 0.04))
	for station in Config.STATIONS:
		var sx := float(station.x)
		var sz := cz + float(station.z)
		_console(Vector3(sx, y, sz), PI, Color("#1b4f72"), Color(0.55, 0.8, 1))
		_chair(Vector3(sx, y, sz - 0.85), 0, Color("#1c2833"))
		_sign(station.name, Vector3(sx, y + 1.15, sz + 0.55), 0, Color(0.7, 0.86, 1))
	_sign("OPERATIONS", Vector3(0, y + 1.7, cz - Config.BRIDGE_HALF + 0.35), PI, Color(0.75, 0.88, 1))
	_light(Vector3(0, y + 2.2, cz + 1.2), Color(0.85, 0.92, 1), 1.3, 9)
	_light(Vector3(0, y + 2.05, screen_z - 1.2), Color(0.65, 0.82, 1), 0.8, 6)

func _build_corridor() -> void:
	var y := Config.OPERATIONS_FLOOR
	var h := Config.DECK_HEIGHT
	var z0 := Config.CORRIDOR_Z0
	var z1 := Config.CORRIDOR_Z1
	var x := Config.CORRIDOR_HALF_X
	var mid := (z0 + z1) * 0.5
	var depth := z1 - z0
	var floor_mat := _panel("#1f5270", "#5dade2")
	_add_box(Vector3(0, y + 0.04, mid), Vector3(x * 2, 0.08, depth), floor_mat, 0, false)
	_add_box(Vector3(0, y + h - 0.04, mid), Vector3(x * 2, 0.08, depth), _flat("#1b242c"), 0, false)
	collision.add_floor(-x - 0.15, x + 0.15, z0, z1, y, y + h)
	_wall(-x, z0, -x, z1, y, h, _panel("#3498db", "#85c1e9"), true, true)
	_wall(x, z0, x, z1, y, h, _panel("#3498db", "#85c1e9"), true, true)
	_zone("corridor", "Bridge Corridor", -x, y, z0, x, y + h, z1)
	_light(Vector3(0, y + 2.1, mid), Color(0.75, 0.88, 1), 0.6, 5)

func _build_elevator() -> void:
	var ind := Config.INDUSTRIAL_FLOOR
	var ops := Config.OPERATIONS_FLOOR
	var civ := Config.CIVILIAN_FLOOR
	var h := Config.DECK_HEIGHT
	var mat := _flat("#8d969e")
	_shaft_level(ind, h, mat, true)
	_shaft_level(ops, h, mat, true)
	_shaft_level(civ, h, mat, true)
	_shaft_level(ind + h, ops - ind - h, mat, false)
	_shaft_level(ops + h, civ - ops - h, mat, false)
	var decks := [ind, ops, civ]
	var names := ["INDUSTRIAL", "OPERATIONS", "CIVILIAN"]
	for i in decks.size():
		_sign("ELEVATOR  " + names[i], Vector3(0, decks[i] + 1.45, Config.SHAFT_OUTER + 0.08), PI, Color(1, 0.92, 0.55))
		_light(Vector3(0, decks[i] + 1.6, 0), Color(1, 0.9, 0.6), 0.45, 3.5)
	_zone("elevator", "Elevator", -Config.SHAFT_OUTER, ind, -Config.SHAFT_OUTER, Config.SHAFT_OUTER, civ + h, Config.SHAFT_OUTER)

func _room_ew(y: float, h: float, mat: Material, x0: float, x1: float, door_z: float, far_z: float, id: String, zone_name: String) -> void:
	var z_near := minf(door_z, far_z)
	var z_far := maxf(door_z, far_z)
	_wall_door(x0, door_z, x1, door_z, y, h, mat)
	_wall(x0, z_near, x0, z_far, y, h, mat)
	_wall(x1, z_near, x1, z_far, y, h, mat)
	if absf(far_z) < Config.HALF - 0.45:
		_wall(x0, far_z, x1, far_z, y, h, mat)
	_zone(id, zone_name, x0, y, z_near, x1, y + h, z_far)

func _room_ns(y: float, h: float, mat: Material, door_x: float, far_x: float, z0: float, z1: float, id: String, zone_name: String) -> void:
	var x_near := minf(door_x, far_x)
	var x_far := maxf(door_x, far_x)
	_wall_door(door_x, z0, door_x, z1, y, h, mat)
	_wall(x_near, z0, x_far, z0, y, h, mat)
	_wall(x_near, z1, x_far, z1, y, h, mat)
	if absf(far_x) < Config.HALF - 0.45:
		_wall(far_x, z0, far_x, z1, y, h, mat)
	_zone(id, zone_name, x_near, y, z0, x_far, y + h, z1)

func _square_deck(y: float, floor_mat: Material, ceil_mat: Material, wall_mat: Material, bow_door: bool, glass_ceil: bool) -> void:
	var half := Config.HALF
	var hole := Config.SHAFT_INNER + 0.15
	var h := Config.DECK_HEIGHT
	_deck_plates(y + 0.04, half, hole, floor_mat, 0.08)
	_deck_plates(y + h - 0.03, half, hole, ceil_mat, 0.06)
	_register_deck(y, y + h, half, hole)
	_wall(-half, -half, -half, half, y, h, wall_mat, true, true)
	_wall(half, -half, half, half, y, h, wall_mat, true, true)
	_wall(-half, -half, half, -half, y, h, wall_mat, true, true)
	if bow_door:
		_wall_door(-half, half, half, half, y, h, wall_mat, 1.7, true)
	else:
		_wall(-half, half, half, half, y, h, wall_mat, true, true)
	if glass_ceil:
		var rim := _emissive(Color(0.7, 0.95, 0.82), 0.25)
		_add_box(Vector3(0, y + h, 0), Vector3(half * 2, 0.08, 0.18), rim, 0, false)
		_add_box(Vector3(0, y + h, 0), Vector3(0.18, 0.08, half * 2), rim, 0, false)

func _deck_plates(y: float, half: float, hole: float, mat: Material, thick: float) -> void:
	_plate(-half, half, -half, -hole, y, mat, thick)
	_plate(-half, half, hole, half, y, mat, thick)
	_plate(-half, -hole, -hole, hole, y, mat, thick)
	_plate(hole, half, -hole, hole, y, mat, thick)

func _plate(x0: float, x1: float, z0: float, z1: float, y: float, mat: Material, thick: float) -> void:
	_add_box(Vector3((x0 + x1) * 0.5, y, (z0 + z1) * 0.5), Vector3(absf(x1 - x0), thick, absf(z1 - z0)), mat, 0, false)

func _register_deck(floor_y: float, ceil_y: float, half: float, hole: float) -> void:
	collision.add_floor(-half, half, -half, -hole, floor_y, ceil_y)
	collision.add_floor(-half, half, hole, half, floor_y, ceil_y)
	collision.add_floor(-half, -hole, -hole, hole, floor_y, ceil_y)
	collision.add_floor(hole, half, -hole, hole, floor_y, ceil_y)

func _shaft_level(y: float, height: float, mat: Material, doors: bool) -> void:
	if height < 0.05:
		return
	var s := Config.SHAFT_OUTER
	if doors:
		_wall_door(-s, -s, -s, s, y, height, mat, 1.15, true)
		_wall_door(s, -s, s, s, y, height, mat, 1.15, true)
		_wall_door(-s, -s, s, -s, y, height, mat, 1.15, true)
		_wall_door(-s, s, s, s, y, height, mat, 1.15, true)
	else:
		_wall(-s, -s, -s, s, y, height, mat, true, true)
		_wall(s, -s, s, s, y, height, mat, true, true)
		_wall(-s, -s, s, -s, y, height, mat, true, true)
		_wall(-s, s, s, s, y, height, mat, true, true)

func _on_perimeter(x1: float, z1: float, x2: float, z2: float) -> bool:
	var edge := Config.HALF - 0.35
	if absf(x1 - x2) < 0.08 and absf(absf(x1) - Config.HALF) < 0.35 and absf(x1) > edge:
		return true
	if absf(z1 - z2) < 0.08 and absf(absf(z1) - Config.HALF) < 0.35 and absf(z1) > edge:
		return true
	return false

func _glass(tint: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = tint
	mat.roughness = 0.08
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return mat

func _zone(id: String, zone_name: String, x0: float, y0: float, z0: float, x1: float, y1: float, z1: float) -> void:
	collision.add_zone(id, zone_name, minf(x0, x1), minf(y0, y1), minf(z0, z1), maxf(x0, x1), maxf(y0, y1), maxf(z0, z1))

func _ring(y: float, mat: Material, inner: float, outer: float) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _ring_mesh(inner, outer)
	mi.position.y = y
	mi.material_override = mat
	add_child(mi)

func _disc(pos: Vector3, radius: float, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.08
	mi.mesh = mesh
	mi.position = pos + Vector3(0, 0.04, 0)
	mi.material_override = mat
	add_child(mi)

func _cylinder(cx: float, cz: float, radius: float, y: float, height: float, mat: Material, openings: Array) -> void:
	var segments := 40
	for i in segments:
		var a0 := TAU * float(i) / segments
		var a1 := TAU * float(i + 1) / segments
		var mid := (a0 + a1) * 0.5
		var skip := false
		for opening in openings:
			if _angle_inside(mid, opening.center, opening.width):
				skip = true
				break
		if skip:
			continue
		var p0 := Vector2(sin(a0) * radius, cos(a0) * radius)
		var p1 := Vector2(sin(a1) * radius, cos(a1) * radius)
		_wall(cx + p0.x, cz + p0.y, cx + p1.x, cz + p1.y, y, height, mat, false)

func _dome(cx: float, y: float, cz: float, radius: float, rise: float, tint: Color) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _dome_mesh(radius, rise)
	mi.position = Vector3(cx, y, cz)
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = tint
	mat.roughness = 0.08
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	mi.material_override = mat
	add_child(mi)
	var lip := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = radius - 0.18
	ring.outer_radius = radius
	lip.mesh = ring
	lip.position = Vector3(cx, y, cz)
	lip.material_override = _emissive(Color(tint.r, tint.g, tint.b), 0.35)
	add_child(lip)

func _wall(x1: float, z1: float, x2: float, z2: float, y: float, height: float, mat: Material, collide: bool = true, force: bool = false) -> void:
	if not force and _on_perimeter(x1, z1, x2, z2):
		return
	var dx := x2 - x1
	var dz := z2 - z1
	var length := Vector2(dx, dz).length()
	if length < 0.05:
		return
	var cx := (x1 + x2) * 0.5
	var cz := (z1 + z2) * 0.5
	var yaw := _yaw_along(dx, dz)
	_add_box(Vector3(cx, y + height * 0.5, cz), Vector3(Config.WALL_THICK, height, length), mat, yaw, false)
	if not collide:
		return
	if absf(dx) < 0.08 or absf(dz) < 0.08:
		var thick := maxf(Config.WALL_THICK, 0.28)
		if absf(dx) >= absf(dz):
			collision.add_box_center(cx, y + height * 0.5, cz, length, height, thick)
		else:
			collision.add_box_center(cx, y + height * 0.5, cz, thick, height, length)

func _wall_door(x1: float, z1: float, x2: float, z2: float, y: float, height: float, mat: Material, door_w: float = 1.15, force: bool = false) -> void:
	var dx := x2 - x1
	var dz := z2 - z1
	var length := Vector2(dx, dz).length()
	if length < door_w + 0.2:
		_wall(x1, z1, x2, z2, y + 2.15, height - 2.15, mat, true, force)
		return
	var ux := dx / length
	var uz := dz / length
	var left := length * 0.5 - door_w * 0.5
	var right := length * 0.5 + door_w * 0.5
	if left > 0.08:
		_wall(x1, z1, x1 + ux * left, z1 + uz * left, y, height, mat, true, force)
	if right < length - 0.08:
		_wall(x1 + ux * right, z1 + uz * right, x2, z2, y, height, mat, true, force)
	_wall(x1 + ux * left, z1 + uz * left, x1 + ux * right, z1 + uz * right, y + 2.15, height - 2.15, mat, true, force)
	var frame := _flat("#c5ced6")
	var mx := (x1 + x2) * 0.5
	var mz := (z1 + z2) * 0.5
	var yaw := _yaw_along(ux, uz)
	_add_box(Vector3(mx - uz * door_w * 0.5, y + 1.075, mz + ux * door_w * 0.5), Vector3(0.08, 2.15, 0.1), frame, yaw, false)
	_add_box(Vector3(mx + uz * door_w * 0.5, y + 1.075, mz - ux * door_w * 0.5), Vector3(0.08, 2.15, 0.1), frame, yaw, false)
	_add_box(Vector3(mx, y + 2.15, mz), Vector3(door_w, 0.08, 0.1), frame, yaw, false)

func _sign(text: String, pos: Vector3, rot_y: float, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = 48
	label.pixel_size = 0.0036
	label.modulate = color
	label.outline_size = 8
	label.outline_modulate = Color(0, 0, 0, 0.8)
	label.position = pos
	label.rotation.y = rot_y
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	add_child(label)

func _console(pos: Vector3, rot_y: float, body: Color, screen: Color) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	add_child(root)
	_add_box_to(root, Vector3(0, 0.48, 0), Vector3(0.95, 0.96, 0.62), _flat("#2b3036"), 0, false)
	_add_box_to(root, Vector3(0, 1.02, -0.05), Vector3(0.9, 0.06, 0.5), _flat(body), 0, false)
	var glow := _add_box_to(root, Vector3(0, 1.22, -0.18), Vector3(0.72, 0.32, 0.04), _emissive(screen, 0.8), 0, false)
	glow.rotation.x = -0.45
	_solid(pos + Vector3(0, 0.55, 0), Vector3(0.95, 1.15, 0.7), rot_y)

func _chair(pos: Vector3, rot_y: float, color: Color) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	add_child(root)
	_add_cyl_to(root, Vector3(0, 0.28, 0), 0.05, 0.56, _flat("#2b3036"))
	_add_cyl_to(root, Vector3(0, 0.58, 0), 0.22, 0.08, _flat(color))
	_add_box_to(root, Vector3(0, 0.82, -0.16), Vector3(0.42, 0.36, 0.06), _flat(color), 0, false)

func _bed(pos: Vector3, rot_y: float, color: Color) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	add_child(root)
	_add_box_to(root, Vector3(0, 0.22, 0), Vector3(2.05, 0.28, 0.95), _flat("#2b3036"), 0, false)
	_add_box_to(root, Vector3(0, 0.4, 0), Vector3(1.95, 0.1, 0.82), _flat(Color(0.94, 0.96, 0.93)), 0, false)
	_add_box_to(root, Vector3(-0.72, 0.5, 0), Vector3(0.42, 0.12, 0.55), _flat(color), 0, false)
	_solid(pos + Vector3(0, 0.25, 0), Vector3(2.05, 0.5, 0.95), rot_y)

func _crate(pos: Vector3, color: Color, scale: float = 0.7) -> void:
	_add_box(pos + Vector3(0, 0.35 * scale, 0), Vector3.ONE * 0.7 * scale, _flat(color), 0, true)

func _plant(pos: Vector3) -> void:
	_add_cyl(pos + Vector3(0, 0.16, 0), 0.08, 0.32, _flat("#6d4c2b"), false)
	_add_sphere(pos + Vector3(0, 0.48, 0), 0.28, _flat("#3d8b5f"))

func _rack(pos: Vector3, rot_y: float, color: Color) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	add_child(root)
	_add_box_to(root, Vector3(0, 1.0, 0), Vector3(0.7, 2.0, 0.32), _flat("#2b3036"), 0, false)
	for i in 4:
		_add_box_to(root, Vector3(0, 0.35 + i * 0.4, 0.12), Vector3(0.58, 0.08, 0.04), _emissive(color, 0.45), 0, false)
	_solid(pos + Vector3(0, 1.0, 0), Vector3(0.7, 2.0, 0.36), rot_y)

func _engine_core(pos: Vector3) -> void:
	_add_cyl(pos + Vector3(0, 0.85, 0), 0.55, 1.7, _flat("#4a4116"), true)
	_add_cyl(pos + Vector3(0, 0.85, 0), 0.28, 1.35, _emissive(Color(1, 0.85, 0.3), 1.1), false)
	_add_sphere(pos + Vector3(0, 1.8, 0), 0.22, _emissive(Color(1, 0.75, 0.25), 1.4))

func _lounge_seat(pos: Vector3, rot_y: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	add_child(root)
	_add_box_to(root, Vector3(0, 0.28, 0), Vector3(1.6, 0.28, 0.62), _flat("#d5f5e3"), 0, false)
	_add_box_to(root, Vector3(0, 0.55, -0.24), Vector3(1.6, 0.32, 0.12), _flat("#a3e4c5"), 0, false)
	_solid(pos + Vector3(0, 0.28, 0), Vector3(1.6, 0.56, 0.7), rot_y)

func _lab_bench(pos: Vector3, rot_y: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation.y = rot_y
	add_child(root)
	_add_box_to(root, Vector3(0, 0.5, 0), Vector3(1.8, 1.0, 0.7), _flat("#1f3d30"), 0, false)
	_add_box_to(root, Vector3(-0.4, 1.08, 0), Vector3(0.4, 0.08, 0.28), _emissive(Color(0.6, 0.9, 0.7), 0.5), 0, false)
	_add_cyl_to(root, Vector3(0.45, 1.2, 0), 0.08, 0.28, _flat(Color(0.85, 0.95, 0.9)))
	_solid(pos + Vector3(0, 0.5, 0), Vector3(1.8, 1.0, 0.7), rot_y)

func _monitor(pos: Vector3, size: Vector3) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 640)
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var display := preload("res://scripts/monitor.gd").new()
	vp.add_child(display)
	add_child(vp)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = vp.get_texture()
	mat.emission_enabled = true
	mat.emission_texture = vp.get_texture()
	mat.emission_energy_multiplier = 0.9
	mat.roughness = 0.25
	_add_box(pos, size, mat, 0, false)

func _light(pos: Vector3, color: Color, energy: float, radius: float) -> void:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.shadow_enabled = false
	add_child(light)

func _strip(pos: Vector3, width: float, color: Color) -> void:
	_add_box(pos, Vector3(width, 0.04, 0.12), _emissive(color, 0.8), 0, false)

func _solid(pos: Vector3, size: Vector3, rot_y: float) -> void:
	var w := size.x
	var d := size.z
	if absf(absf(rot_y) - PI * 0.5) < 0.35 or absf(absf(rot_y) - PI * 1.5) < 0.35:
		w = size.z
		d = size.x
	collision.add_box_center(pos.x, pos.y, pos.z, w, size.y, d)

func _add_box(pos: Vector3, size: Vector3, mat: Material, rot_y: float, collide: bool) -> MeshInstance3D:
	var mi := _add_box_to(self, pos, size, mat, rot_y, collide)
	return mi

func _add_box_to(parent: Node3D, pos: Vector3, size: Vector3, mat: Material, rot_y: float, collide: bool) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation.y = rot_y
	mi.material_override = mat
	parent.add_child(mi)
	if collide:
		_solid(parent.to_global(pos) if parent != self else pos, size, rot_y)
	return mi

func _add_cyl(pos: Vector3, radius: float, height: float, mat: Material, collide: bool) -> void:
	_add_cyl_to(self, pos, radius, height, mat)
	if collide:
		collision.add_box_center(pos.x, pos.y, pos.z, radius * 2.0, height, radius * 2.0)

func _add_cyl_to(parent: Node3D, pos: Vector3, radius: float, height: float, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	parent.add_child(mi)

func _add_sphere(pos: Vector3, radius: float, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	add_child(mi)

func _panel(base_hex: String, line_hex: String) -> StandardMaterial3D:
	var base := Color.html(base_hex)
	var line := Color.html(line_hex)
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(base)
	for i in 8:
		for x in 64:
			img.set_pixel(x, i * 8, line)
			img.set_pixel(i * 8, x, line)
	var tex := ImageTexture.create_from_image(img)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(0.45, 0.45, 0.45)
	mat.roughness = 0.78
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat

func _flat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.7
	return mat

func _emissive(color: Color, energy: float) -> StandardMaterial3D:
	var mat := _flat(color)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = energy
	return mat

func _ring_mesh(inner: float, outer: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 48
	for i in segments:
		var a0 := TAU * float(i) / segments
		var a1 := TAU * float(i + 1) / segments
		var o0 := Vector3(sin(a0) * outer, 0, cos(a0) * outer)
		var o1 := Vector3(sin(a1) * outer, 0, cos(a1) * outer)
		var i0 := Vector3(sin(a0) * inner, 0, cos(a0) * inner)
		var i1 := Vector3(sin(a1) * inner, 0, cos(a1) * inner)
		_tri(st, o0, i0, i1)
		_tri(st, o0, i1, o1)
	st.generate_normals()
	return st.commit()

func _dome_mesh(radius: float, rise: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings := 8
	var segments := 36
	for lat in rings:
		var phi0 := (float(lat) / rings) * PI * 0.5
		var phi1 := (float(lat + 1) / rings) * PI * 0.5
		for lon in segments:
			var th0 := TAU * float(lon) / segments
			var th1 := TAU * float(lon + 1) / segments
			var p00 := _dome_point(phi0, th0, radius, rise)
			var p01 := _dome_point(phi0, th1, radius, rise)
			var p10 := _dome_point(phi1, th0, radius, rise)
			var p11 := _dome_point(phi1, th1, radius, rise)
			_tri(st, p00, p10, p11)
			_tri(st, p00, p11, p01)
	st.generate_normals()
	return st.commit()

func _dome_point(phi: float, theta: float, radius: float, rise: float) -> Vector3:
	var y := cos(phi) * rise
	var ring := sin(phi) * radius
	return Vector3(sin(theta) * ring, y, cos(theta) * ring)

func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_uv(Vector2(a.x, a.z) * 0.2)
	st.add_vertex(a)
	st.set_uv(Vector2(b.x, b.z) * 0.2)
	st.add_vertex(b)
	st.set_uv(Vector2(c.x, c.z) * 0.2)
	st.add_vertex(c)

func _yaw_along(dx: float, dz: float) -> float:
	# Godot local +Z points to (-sin(yaw), cos(yaw)) after a Y rotation.
	return atan2(-dx, dz)

func _angle_inside(angle: float, center: float, width: float) -> bool:
	return absf(wrapf(angle - center, -PI, PI)) <= width * 0.5
