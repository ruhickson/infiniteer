extends CanvasLayer

const Config = preload("res://scripts/config.gd")
const SolarSystem = preload("res://scripts/solar_system.gd")

const TABLE_X := 0.0
const TABLE_Z := Config.AVOCA_ORRERY_Z
const USE_RADIUS := 3.35

var system
var orrery
var player
var charting := false
var selected := ""
var room_rate: float = 0.0
var prompt: Label
var panel: PanelContainer
var course_label: Label
var body_buttons := {}
var rate_buttons := {}
var _shown_rate := -99.0

func setup(solar_system, orrery_node, player_node) -> void:
	layer = 5
	system = solar_system
	orrery = orrery_node
	player = player_node
	_build_prompt()
	_build_panel()

func is_charting() -> bool:
	return charting

func handle_chart_key() -> bool:
	if charting:
		close_chart()
		return true
	if player == null or not player.active or not _near():
		return false
	open_chart()
	return true

func open_chart() -> void:
	charting = true
	room_rate = float(system.rate)
	system.rate = 0.0
	_shown_rate = -99.0
	panel.show()
	player.active = false
	player.held.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_text()
	_style_bodies()
	_style_rates()

func close_chart() -> void:
	if not charting:
		return
	charting = false
	panel.hide()
	system.rate = room_rate
	player.active = true
	player.held.clear()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func select_body(id: String) -> void:
	if id == selected:
		selected = ""
	else:
		selected = id
	orrery.destination = selected
	orrery.refresh()
	_style_bodies()
	_refresh_text()

func _process(_delta: float) -> void:
	if player == null or system == null:
		return
	prompt.visible = _near() and not charting and player.active
	if not charting:
		return
	if absf(system.rate - _shown_rate) > 0.001:
		_shown_rate = system.rate
		_style_rates()
	_refresh_text()

func _near() -> bool:
	var feet: Vector3 = player.global_position
	var flat := Vector2(feet.x - TABLE_X, feet.z - TABLE_Z)
	if flat.length() > USE_RADIUS:
		return false
	return absf(feet.y - Config.AVOCA_FLOOR) <= 1.6

func _refresh_text() -> void:
	course_label.text = system.page(selected)

func _build_prompt() -> void:
	prompt = Label.new()
	prompt.text = "E    Chart a course"
	prompt.anchor_left = 0.5
	prompt.anchor_right = 0.5
	prompt.anchor_top = 1.0
	prompt.anchor_bottom = 1.0
	prompt.offset_left = -180.0
	prompt.offset_right = 180.0
	prompt.offset_top = -78.0
	prompt.offset_bottom = -48.0
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 18)
	prompt.add_theme_color_override("font_color", Color(0.82, 0.93, 1.0))
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.visible = false
	add_child(prompt)

func _build_panel() -> void:
	panel = PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -500.0
	panel.offset_top = 16.0
	panel.offset_right = -16.0
	panel.offset_bottom = -16.0
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.03, 0.06, 0.1, 0.94)
	box.border_color = Color(0.35, 0.62, 0.85, 0.9)
	box.set_border_width_all(1)
	box.set_corner_radius_all(6)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 14
	box.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", box)
	panel.hide()
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	var title := Label.new()
	title.text = "NAVIGATION PLOT"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.78, 0.9, 1.0))
	column.add_child(title)
	column.add_child(_section("PLANETS"))
	column.add_child(_body_grid(system.planet_ids))
	column.add_child(_section("JOVIAN MOONS"))
	column.add_child(_body_grid(system.moon_ids))
	course_label = Label.new()
	course_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	course_label.add_theme_font_size_override("font_size", 15)
	course_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	course_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(course_label)
	var rates := HBoxContainer.new()
	rates.add_theme_constant_override("separation", 6)
	column.add_child(rates)
	_rate_button(rates, "Hold", 0.0)
	_rate_button(rates, "Watch", SolarSystem.WATCH_RATE)
	_rate_button(rates, "Fast", 24.0)
	_rate_button(rates, "Sweep", 120.0)
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 8)
	column.add_child(foot)
	var hint := Label.new()
	hint.text = "E or Esc closes"
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.7, 0.82, 0.95, 0.8))
	foot.add_child(hint)
	var close := Button.new()
	close.text = "Close"
	close.pressed.connect(close_chart)
	_paint(close, Color(0.25, 0.45, 0.62), false)
	foot.add_child(close)

func _section(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.55, 0.75, 0.9, 0.85))
	return label

func _body_grid(ids: Array) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	for raw_id in ids:
		var id := String(raw_id)
		var button := Button.new()
		button.text = id
		button.custom_minimum_size = Vector2(108, 32)
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(select_body.bind(id))
		grid.add_child(button)
		body_buttons[id] = button
	return grid

func _rate_button(parent: HBoxContainer, text: String, rate_value: float) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(100, 32)
	button.add_theme_font_size_override("font_size", 13)
	button.pressed.connect(_set_rate.bind(rate_value))
	parent.add_child(button)
	rate_buttons[text] = button

func _set_rate(rate_value: float) -> void:
	system.rate = rate_value
	room_rate = rate_value

func _style_bodies() -> void:
	for raw_id in body_buttons.keys():
		var id := String(raw_id)
		var button: Button = body_buttons[id]
		_paint(button, system.body_color(id), id == selected)

func _style_rates() -> void:
	var names := ["Hold", "Watch", "Fast", "Sweep"]
	var values := [0.0, SolarSystem.WATCH_RATE, 24.0, 120.0]
	for i in names.size():
		var button: Button = rate_buttons[names[i]]
		var hot: bool = absf(float(system.rate) - values[i]) < 0.001
		_paint(button, Color(0.30, 0.55, 0.75), hot)

func _paint(button: Button, base: Color, hot: bool) -> void:
	var bg := base
	if hot:
		bg = bg.lightened(0.2)
	else:
		bg = bg.darkened(0.42)
	bg.a = 1.0
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(3)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	if hot:
		style.border_color = Color(1, 1, 1, 0.92)
		style.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
