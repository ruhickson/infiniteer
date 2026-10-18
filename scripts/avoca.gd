extends "res://scripts/ship.gd"

# S.F. Avoca — a single cabin the footprint of Shannon's Bridge, 50% wider.
# Scaffold for more decks and detail later.

func _ready() -> void:
	_build_cabin()

func _build_cabin() -> void:
	var y := Config.AVOCA_FLOOR
	var h := Config.DECK_HEIGHT
	var hx := Config.AVOCA_HALF_X
	var hz := Config.AVOCA_HALF_Z
	var floor_mat := _panel("#273746", "#5d6d7e")
	var wall_mat := _panel("#2c3e50", "#7f8c9b")
	_add_box(Vector3(0, y + 0.04, 0), Vector3(hx * 2, 0.08, hz * 2), floor_mat, 0, false)
	_add_box(Vector3(0, y + h - 0.04, 0), Vector3(hx * 2, 0.06, hz * 2), _glass(Color(0.75, 0.88, 1, 0.16)), 0, false)
	collision.add_floor(-hx, hx, -hz, hz, y, y + h)
	_wall(-hx, -hz, -hx, hz, y, h, wall_mat, true, true)
	_wall(hx, -hz, hx, hz, y, h, wall_mat, true, true)
	_wall(-hx, hz, hx, hz, y, h, wall_mat, true, true)
	_wall_door(-hx, -hz, hx, -hz, y, h, wall_mat, 1.7, true)
	_zone("bridge", "Bridge", -hx, y, -hz, hx, y + h, hz)
	var screen_z := hz - 0.7
	_add_box(Vector3(0, y + 1.35, screen_z + 0.08), Vector3(12.2, 1.55, 0.12), _flat("#10161c"), 0, true)
	_monitor(Vector3(0, y + 1.35, screen_z), Vector3(11.6, 1.4, 0.04))
	for station in Config.AVOCA_STATIONS:
		var sx := float(station.x)
		var sz := float(station.z)
		_console(Vector3(sx, y, sz), PI, Color("#1b4f72"), Color(0.55, 0.8, 1))
		_chair(Vector3(sx, y, sz - 0.85), 0, Color("#1c2833"))
		_sign(station.name, Vector3(sx, y + 1.15, sz + 0.55), 0, Color(0.7, 0.86, 1))
	_add_cyl(Vector3(0, y + 0.18, Config.AVOCA_ORRERY_Z), 0.22, 0.36, _flat("#16384d"), false)
	_add_cyl(Vector3(0, y + 0.45, Config.AVOCA_ORRERY_Z), 1.7, 0.16, _flat("#1a4c72"), true)
	_add_cyl(Vector3(0, y + 0.56, Config.AVOCA_ORRERY_Z), 1.25, 0.05, _emissive(Color(0.45, 0.75, 1), 0.7), false)
	_sign("SYSTEM PLOT", Vector3(0, y + 1.2, Config.AVOCA_ORRERY_Z - 2.45), 0, Color(0.75, 0.9, 1))
	orrery = OrreryScript.new()
	orrery.name = "Orrery"
	orrery.position = Vector3(0, y + 0.70, Config.AVOCA_ORRERY_Z)
	orrery.setup(solar)
	add_child(orrery)
	_console(Vector3(-4.2, y, Config.AVOCA_ORRERY_Z + 1.2), 0.4, Color("#2e86c1"), Color(0.55, 0.85, 1))
	_console(Vector3(4.2, y, Config.AVOCA_ORRERY_Z + 1.2), -0.4, Color("#2e86c1"), Color(0.55, 0.85, 1))
	_sign("S.F. AVOCA", Vector3(0, y + 1.7, -hz + 0.35), PI, Color(0.75, 0.88, 1))
	_light(Vector3(0, y + 2.2, 1.2), Color(0.85, 0.92, 1), 1.3, 10)
	_light(Vector3(0, y + 2.05, screen_z - 1.2), Color(0.65, 0.82, 1), 0.8, 7)
	_light(Vector3(0, y + 2.15, Config.AVOCA_ORRERY_Z), Color(0.55, 0.78, 1), 1.2, 9)
