extends RefCounted

const Config = preload("res://scripts/config.gd")

var boxes: Array = []
var floors: Array = []
var zones: Array = []

func add_box(min_x: float, min_y: float, min_z: float, max_x: float, max_y: float, max_z: float) -> void:
	boxes.append({
		"min_x": min_x, "min_y": min_y, "min_z": min_z,
		"max_x": max_x, "max_y": max_y, "max_z": max_z,
	})

func add_box_center(cx: float, cy: float, cz: float, w: float, h: float, d: float) -> void:
	add_box(cx - w * 0.5, cy - h * 0.5, cz - d * 0.5, cx + w * 0.5, cy + h * 0.5, cz + d * 0.5)

func add_floor(min_x: float, max_x: float, min_z: float, max_z: float, floor_y: float, ceil_y: float) -> void:
	floors.append({
		"min_x": min_x, "max_x": max_x, "min_z": min_z, "max_z": max_z,
		"floor_y": floor_y, "ceil_y": ceil_y,
	})

func add_zone(id: String, zone_name: String, min_x: float, min_y: float, min_z: float, max_x: float, max_y: float, max_z: float) -> void:
	zones.append({
		"id": id, "name": zone_name,
		"min_x": min_x, "min_y": min_y, "min_z": min_z,
		"max_x": max_x, "max_y": max_y, "max_z": max_z,
	})

func resolve(feet: Vector3) -> Vector3:
	var mid := feet + Vector3(0, Config.PLAYER_HEIGHT * 0.5, 0)
	for _pass in 3:
		for box in boxes:
			mid = _resolve_box(mid, box)
	feet = mid - Vector3(0, Config.PLAYER_HEIGHT * 0.5, 0)
	for floor in floors:
		feet = _resolve_floor(feet, floor)
	if feet.y < Config.INDUSTRIAL_FLOOR:
		feet.y = Config.INDUSTRIAL_FLOOR
	return feet

func locate(feet: Vector3) -> Dictionary:
	var best := {}
	var best_volume := INF
	var sample := feet + Vector3(0, 0.4, 0)
	for zone in zones:
		if sample.x < _num(zone.min_x) or sample.x > _num(zone.max_x):
			continue
		if sample.y < _num(zone.min_y) or sample.y > _num(zone.max_y):
			continue
		if sample.z < _num(zone.min_z) or sample.z > _num(zone.max_z):
			continue
		var volume := (_num(zone.max_x) - _num(zone.min_x)) * (_num(zone.max_z) - _num(zone.min_z))
		if volume < best_volume:
			best = zone
			best_volume = volume
	return best

func _resolve_box(pos: Vector3, box: Dictionary) -> Vector3:
	var r := Config.PLAYER_RADIUS
	var min_x := _num(box.min_x)
	var max_x := _num(box.max_x)
	var min_y := _num(box.min_y)
	var max_y := _num(box.max_y)
	var min_z := _num(box.min_z)
	var max_z := _num(box.max_z)
	if pos.x + r <= min_x or pos.x - r >= max_x:
		return pos
	if pos.y + r <= min_y or pos.y - r >= max_y:
		return pos
	if pos.z + r <= min_z or pos.z - r >= max_z:
		return pos
	var dx1 := pos.x + r - min_x
	var dx2 := max_x - (pos.x - r)
	var dy1 := pos.y + r - min_y
	var dy2 := max_y - (pos.y - r)
	var dz1 := pos.z + r - min_z
	var dz2 := max_z - (pos.z - r)
	var axis := 0
	var depth := dx1
	var sign := -1.0
	if dx2 < depth:
		depth = dx2
		sign = 1.0
		axis = 0
	if dy1 < depth:
		depth = dy1
		sign = -1.0
		axis = 1
	if dy2 < depth:
		depth = dy2
		sign = 1.0
		axis = 1
	if dz1 < depth:
		depth = dz1
		sign = -1.0
		axis = 2
	if dz2 < depth:
		depth = dz2
		sign = 1.0
		axis = 2
	pos[axis] += sign * (depth + 0.001)
	return pos

func _resolve_floor(feet: Vector3, floor: Dictionary) -> Vector3:
	if feet.x < _num(floor.min_x) or feet.x > _num(floor.max_x):
		return feet
	if feet.z < _num(floor.min_z) or feet.z > _num(floor.max_z):
		return feet
	var floor_y := _num(floor.floor_y)
	var ceil_y := _num(floor.ceil_y)
	if feet.y < floor_y and feet.y > floor_y - 1.6:
		feet.y = floor_y
	if ceil_y >= 0.0:
		var head := feet.y + Config.PLAYER_HEIGHT
		if head > ceil_y and head < ceil_y + 1.6:
			feet.y = ceil_y - Config.PLAYER_HEIGHT
	return feet

func _num(value) -> float:
	return float(value)
