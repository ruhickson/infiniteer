extends SceneTree

const Config = preload("res://scripts/config.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var player = main.get_node("Player")
	var col = player.collision
	var fails: Array = []
	var fwd: Vector3 = -player.global_transform.basis.z
	print("FORWARD ", fwd)
	var yaw_node := Node3D.new()
	main.add_child(yaw_node)
	yaw_node.rotation.y = atan2(-1.0, 0.0)
	print("WALL_BASIS_Z ", yaw_node.global_transform.basis.z)

	_expect(col, fails, "bridge", Vector3(0, Config.OPERATIONS_FLOOR, Config.BRIDGE_CZ - 1.0), "Bridge")
	_expect(col, fails, "nav", Vector3(0, Config.OPERATIONS_FLOOR, 12), "Navigation")
	_expect(col, fails, "comms", Vector3(0, Config.OPERATIONS_FLOOR, -12), "Communications")
	_expect(col, fails, "corridor", Vector3(0, Config.OPERATIONS_FLOOR, 25.6), "Bridge Corridor")
	_expect(col, fails, "shaft", Vector3(0, Config.OPERATIONS_FLOOR, 0), "Elevator")
	_expect(col, fails, "engine", Vector3(0, Config.INDUSTRIAL_FLOOR, -12), "Engine Room")
	_expect(col, fails, "systems", Vector3(-13, Config.INDUSTRIAL_FLOOR, 0), "Systems")
	_expect(col, fails, "hold", Vector3(-10, Config.INDUSTRIAL_FLOOR, 11), "Hold")
	_expect(col, fails, "weapons", Vector3(10, Config.INDUSTRIAL_FLOOR, 11), "Weapons")
	_expect(col, fails, "emergency", Vector3(13, Config.INDUSTRIAL_FLOOR, 0), "Emergency")
	_expect(col, fails, "quarters", Vector3(-4.5, Config.CIVILIAN_FLOOR, -11.2), "Quarters 01")
	_expect(col, fails, "quarters4", Vector3(4.5, Config.CIVILIAN_FLOOR, -17.3), "Quarters 04")
	_expect(col, fails, "procurement", Vector3(-13, Config.CIVILIAN_FLOOR, 0), "Procurement")
	_expect(col, fails, "lab", Vector3(13, Config.CIVILIAN_FLOOR, 0), "Laboratory")
	_expect(col, fails, "lounge", Vector3(0, Config.CIVILIAN_FLOOR, 12), "Lounge")

	var walker := Vector3(16, Config.INDUSTRIAL_FLOOR, 0)
	for _step in 80:
		walker.x += 0.25
		walker = col.resolve(walker)
	print("HULL ", walker)
	if walker.x > 24.75:
		fails.append("hull leaked %s" % walker)

	player.active = true
	player.global_position = Vector3(0, Config.INDUSTRIAL_FLOOR, -12)
	player.held.clear()
	player.held[KEY_SPACE] = true
	for _step in 50:
		player._physics_process(0.05)
	print("CEILING ", player.global_position.y)
	if player.global_position.y > 1.05:
		fails.append("ceiling leaked %s" % player.global_position.y)
	player.held.clear()
	player.global_position = Vector3(0, Config.OPERATIONS_FLOOR, Config.BRIDGE_CZ - 1.35)

	var toward := Vector3(5.2, Config.OPERATIONS_FLOOR, Config.BRIDGE_CZ - 4.0)
	for _step in 50:
		toward.z += 0.3
		toward = col.resolve(toward)
	print("FRONT_WALL ", toward)
	if toward.z > Config.BRIDGE_CZ + Config.BRIDGE_HALF - 0.15:
		fails.append("front wall failed %s" % toward)
	if toward.z < Config.BRIDGE_CZ + 3.0:
		fails.append("front wall blocked too early %s" % toward)

	var blocked := Vector3(-2, Config.INDUSTRIAL_FLOOR, -4)
	for _step in 30:
		blocked.x -= 0.25
		blocked = col.resolve(blocked)
	print("SOLID_WALL ", blocked)
	if blocked.x < -7.15:
		fails.append("systems wall failed %s" % blocked)

	player.active = true
	player.held[KEY_W] = true
	var start: Vector3 = player.global_position
	for _i in 8:
		player._physics_process(0.05)
	var moved: Vector3 = player.global_position
	print("MOVE_W ", start, " -> ", moved)
	if moved.z <= start.z + 0.2:
		fails.append("W did not move forward")
	player.held.clear()
	player.global_position = start
	player.held[KEY_SPACE] = true
	for _i in 6:
		player._physics_process(0.05)
	print("MOVE_UP ", player.global_position.y)
	if player.global_position.y < start.y + 0.4:
		fails.append("Space did not raise the player")

	var into_engine := Vector3(0, Config.INDUSTRIAL_FLOOR, -4)
	for _step in 40:
		into_engine.z -= 0.2
		into_engine = col.resolve(into_engine)
	print("DOOR_ENGINE ", into_engine, " ", col.locate(into_engine).get("name", ""))
	if into_engine.z > -8.0:
		fails.append("engine door blocked at %s" % into_engine)

	var to_bridge := Vector3(0, Config.OPERATIONS_FLOOR, 20)
	for _step in 70:
		to_bridge.z += 0.25
		to_bridge = col.resolve(to_bridge)
	print("DOOR_BRIDGE ", to_bridge, " ", col.locate(to_bridge).get("name", ""))
	if to_bridge.z < Config.BRIDGE_CZ - 2.0:
		fails.append("bridge door blocked at %s" % to_bridge)

	var down := Vector3(0, Config.OPERATIONS_FLOOR, 0)
	for _step in 40:
		down.y -= 0.12
		down = col.resolve(down)
	print("ELEVATOR_DOWN ", down, " ", col.locate(down).get("name", ""))
	if down.y > 0.2:
		fails.append("elevator blocked at %s" % down)

	var solar = main.get_node("Ship").solar
	var clock: String = solar.page("")
	print("CLOCK ", clock.split("\n")[0])
	if "18 Oct 2026" not in clock:
		fails.append("clock %s" % clock.split("\n")[0])
	for raw_id in solar.planet_ids:
		var pid := String(raw_id)
		var pos: Vector3 = solar.body_position(pid, solar.day)
		var radius: float = pos.length()
		var axis: float = float(solar.bodies[pid]["a"])
		var ecc: float = float(solar.bodies[pid]["e"])
		print("ORBIT ", pid, " ", radius)
		if radius < axis * (1.0 - ecc) * 0.98 or radius > axis * (1.0 + ecc) * 1.02:
			fails.append("%s radius %s" % [pid, radius])
	var earth_now: Vector3 = solar.body_position("Earth", solar.day)
	var earth_later: Vector3 = solar.body_position("Earth", solar.day + 40.0)
	if earth_now.distance_to(earth_later) < 0.4:
		fails.append("earth did not move")
	var ship_fix: Vector3 = solar.ship_position(solar.day)
	var jupiter_fix: Vector3 = solar.body_position("Jupiter", solar.day)
	var ship_gap: float = ship_fix.distance_to(jupiter_fix)
	print("SHIP_JUP ", ship_gap)
	if ship_gap < 0.005 or ship_gap > 0.02:
		fails.append("ship not off Jupiter %s" % ship_gap)
	var saturn: Dictionary = solar.plot("Saturn")
	print("SATURN days ", saturn["days"], " fuel ", saturn["fuel"])
	if not bool(saturn["solvable"]):
		fails.append("saturn not solvable")
	var saturn_days: float = float(saturn["days"])
	var saturn_dir: Vector3 = saturn["direction"]
	if absf(saturn_dir.length() - 1.0) > 0.02:
		fails.append("saturn direction %s" % saturn_dir)
	var saturn_then: Vector3 = solar.body_position("Saturn", solar.day + saturn_days)
	var flown: float = ship_fix.distance_to(saturn_then)
	if absf(flown - solar.CRUISE_AU_PER_DAY * saturn_days) > 0.03:
		fails.append("saturn intercept %s vs %s" % [flown, solar.CRUISE_AU_PER_DAY * saturn_days])
	var fuel_sum: float = float(saturn["depart"]) + float(saturn["arrive"]) + float(saturn["cruise"])
	if absf(fuel_sum - float(saturn["fuel"])) > 0.01:
		fails.append("fuel parts %s vs %s" % [fuel_sum, saturn["fuel"]])
	var ganymede: Dictionary = solar.plot("Ganymede")
	print("GANYMEDE days ", ganymede["days"], " fuel ", ganymede["fuel"])
	if not bool(ganymede["solvable"]) or float(ganymede["days"]) > 2.0 or float(ganymede["days"]) <= 0.0:
		fails.append("ganymede hop %s" % ganymede["days"])
	var station: Dictionary = solar.plot("Jupiter")
	if bool(station["solvable"]):
		fails.append("jupiter plotted a departure")
	var nep_vis: Vector3 = solar.to_table(solar.body_position("Neptune", solar.day))
	if Vector2(nep_vis.x, nep_vis.z).length() > 1.22:
		fails.append("neptune off the glass %s" % nep_vis)
	var orrery = main.get_node("Ship/Orrery")
	var earth_node: Node3D = orrery.get_node("Earth")
	if earth_node.position.length() < 0.1:
		fails.append("earth marker missing")
	player.global_position = Vector3(0, Config.OPERATIONS_FLOOR, 9.6)
	player.active = true
	var nav = main.get_node("NavConsole")
	if not nav.handle_chart_key():
		fails.append("chart did not open")
	else:
		nav.select_body("Mars")
		var written: String = nav.course_label.text
		print("NAV ", written.split("\n")[0])
		if "Mars" not in written or "Fuel" not in written or "Bearing" not in written:
			fails.append("nav readout incomplete")
		var course_mesh: MeshInstance3D = orrery.get_node("Course")
		if course_mesh.mesh.get_surface_count() < 1:
			fails.append("no course line")
		nav.close_chart()

	if fails.is_empty():
		print("SMOKE_OK")
		quit(0)
	else:
		print("SMOKE_FAIL ", fails)
		quit(1)

func _expect(col, fails: Array, tag: String, feet: Vector3, zone_name: String) -> void:
	var resolved: Vector3 = col.resolve(feet)
	var zone: Dictionary = col.locate(resolved)
	var found: String = zone.get("name", "")
	print(tag, " ", resolved, " ", found)
	if found != zone_name:
		fails.append("%s expected %s got %s at %s" % [tag, zone_name, found, resolved])
