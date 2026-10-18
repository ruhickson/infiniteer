extends Node3D

const Config = preload("res://scripts/config.gd")

var collision
var camera: Camera3D
var held := {}
var active := false
var yaw := PI
var pitch := -0.08

func setup(collision_world) -> void:
	collision = collision_world

func _ready() -> void:
	name = "Player"
	var floor_y: float = Config.OPERATIONS_FLOOR
	global_position = Vector3(0, floor_y, Config.BRIDGE_CZ - 1.35)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 74
	camera.near = 0.05
	camera.far = 400
	camera.position = Vector3(0, Config.EYE_HEIGHT, 0)
	add_child(camera)
	rotation.y = yaw
	camera.rotation.x = pitch

func feet_position() -> Vector3:
	return global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and active:
		yaw -= event.relative.x * 0.0022
		pitch -= event.relative.y * 0.0022
		pitch = clampf(pitch, -1.15, 1.15)
		rotation.y = yaw
		camera.rotation.x = pitch
	elif event is InputEventKey:
		if event.echo:
			return
		held[event.physical_keycode] = event.pressed
		if event.pressed and event.physical_keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_SPACE, KEY_CTRL]:
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if not active:
		return
	var dt := minf(delta, 0.05)
	var forward := -global_transform.basis.z
	forward.y = 0
	if forward.length_squared() < 0.0001:
		forward = Vector3(0, 0, 1)
	else:
		forward = forward.normalized()
	var right := global_transform.basis.x
	right.y = 0
	right = right.normalized()
	var wish := Vector3.ZERO
	if held.get(KEY_W, false):
		wish += forward
	if held.get(KEY_S, false):
		wish -= forward
	if held.get(KEY_D, false):
		wish += right
	if held.get(KEY_A, false):
		wish -= right
	if wish.length_squared() > 0.0:
		global_position += wish.normalized() * Config.MOVE_SPEED * dt
	if held.get(KEY_SPACE, false):
		global_position.y += Config.VERTICAL_SPEED * dt
	if held.get(KEY_CTRL, false):
		global_position.y -= Config.VERTICAL_SPEED * dt
	global_position = collision.resolve(global_position)
