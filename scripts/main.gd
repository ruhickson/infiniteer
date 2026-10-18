extends Node3D

const Config = preload("res://scripts/config.gd")
const CollisionWorld = preload("res://scripts/collision.gd")
const Ship = preload("res://scripts/ship.gd")
const Player = preload("res://scripts/player.gd")
const Starfield = preload("res://scripts/starfield.gd")
const NavConsole = preload("res://scripts/nav_console.gd")

var collision
var player
var nav_console
var location_label: Label
var overlay: Control

func _ready() -> void:
	_environment()
	collision = CollisionWorld.new()
	var ship = Ship.new()
	ship.name = "Ship"
	ship.setup(collision)
	add_child(ship)
	var stars = Starfield.new()
	stars.name = "Starfield"
	add_child(stars)
	player = Player.new()
	player.setup(collision)
	add_child(player)
	nav_console = NavConsole.new()
	nav_console.name = "NavConsole"
	add_child(nav_console)
	nav_console.setup(ship.solar, ship.orrery, player)
	_hud()

func _environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.012, 0.018, 0.03)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.68, 0.75, 0.82)
	env.ambient_light_energy = 0.42
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 30, 0)
	sun.light_color = Color(0.85, 0.91, 1)
	sun.light_energy = 0.35
	add_child(sun)

func _hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	location_label = Label.new()
	location_label.text = "Bridge  ·  S.F. Shannon"
	location_label.position = Vector2(28, 24)
	location_label.add_theme_font_size_override("font_size", 22)
	location_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1))
	location_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(location_label)
	var title := Label.new()
	title.text = "INFINITEER"
	title.position = Vector2(28, 8)
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(title)
	var hint := Label.new()
	hint.text = "WASD move     SPACE / CTRL altitude     MOUSE look     ESC release"
	hint.anchor_left = 0
	hint.anchor_top = 1
	hint.offset_left = 28
	hint.offset_top = -36
	hint.offset_right = 900
	hint.offset_bottom = -12
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hint)
	var cross := ColorRect.new()
	cross.color = Color(1, 1, 1, 0.85)
	cross.anchor_left = 0.5
	cross.anchor_top = 0.5
	cross.anchor_right = 0.5
	cross.anchor_bottom = 0.5
	cross.offset_left = -2
	cross.offset_top = -2
	cross.offset_right = 2
	cross.offset_bottom = 2
	cross.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(cross)
	overlay = _overlay()
	layer.add_child(overlay)

func _overlay() -> Control:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.04, 0.07, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.add_child(center)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(560, 0)
	center.add_child(box)
	_overlay_label(box, "SOLAR FLYER", 13, Color(1, 1, 1, 0.55))
	_overlay_label(box, "INFINITEER", 52, Color(0.95, 0.97, 1))
	_overlay_label(box, "S.F. SHANNON", 16, Color(0.56, 0.82, 1))
	var story := _overlay_label(box, "You are Attom, an android newly rebooted after time in a robot penitentiary off one of Jupiter's moons. The ship is quiet. The decks are waiting.", 16, Color(1, 1, 1, 0.82))
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.custom_minimum_size = Vector2(520, 80)
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_label(box, "Click to enter the Bridge", 20, Color(1, 1, 1))
	_overlay_label(box, "WASD move   ·   SPACE up   ·   CTRL down   ·   MOUSE look", 12, Color(1, 1, 1, 0.55))
	dim.gui_input.connect(_on_overlay_input)
	return dim

func _overlay_label(parent: Node, text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_capture()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		if nav_console != null and nav_console.handle_chart_key():
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and not player.active:
		if nav_console != null and nav_console.is_charting():
			return
		_capture()
	elif event.is_action_pressed("ui_cancel"):
		if nav_console != null and nav_console.is_charting():
			nav_console.close_chart()
			get_viewport().set_input_as_handled()
			return
		if player.active:
			player.active = false
			player.held.clear()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			overlay.show()

func _capture() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.active = true
	overlay.hide()

func _process(_delta: float) -> void:
	if player == null:
		return
	var zone: Dictionary = collision.locate(player.feet_position())
	var where := "S.F. Shannon"
	if not zone.is_empty():
		where = "%s  ·  S.F. Shannon" % zone.name
	location_label.text = where
