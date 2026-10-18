extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size_px := size
	if size_px.x < 2.0:
		size_px = Vector2(1280, 640)
	draw_rect(Rect2(Vector2.ZERO, size_px), Color(0.024, 0.05, 0.075))
	var view := Rect2(size_px.x * 0.54, 28, size_px.x * 0.42, size_px.y - 56)
	draw_rect(view, Color(0.008, 0.016, 0.03))
	draw_rect(view, Color(0.18, 0.42, 0.55), false, 3.0)
	var t := Time.get_ticks_msec() / 1000.0
	for i in 70:
		var drift := fmod(t * 28.0 + i * 37.0, view.size.x)
		var y := view.position.y + (0.5 + 0.5 * sin(i * 1.7)) * view.size.y
		draw_rect(Rect2(view.position.x + drift, y, 2, 2), Color(1, 1, 1, 0.75))
	draw_circle(view.position + Vector2(view.size.x * 0.72, view.size.y * 0.28), 16, Color(0.55, 0.72, 0.86))
	draw_circle(view.position + Vector2(view.size.x * 0.22, view.size.y * 0.7), 7, Color(0.76, 0.6, 0.42))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(36, 58), "S.F. SHANNON", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color(0.62, 0.85, 1))
	draw_string(font, Vector2(36, 92), "SOLAR FLYER   REGISTRY SF-7714", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.45, 0.66, 0.78))
	var rows := [
		["PROPULSION", "NOMINAL", Color(0.56, 0.88, 0.69)],
		["LIFE SUPPORT", "NOMINAL", Color(0.56, 0.88, 0.69)],
		["NAVIGATION", "PLOTTING", Color(0.56, 0.88, 0.69)],
		["COMMS", "LISTENING", Color(0.56, 0.88, 0.69)],
		["WEAPONS", "SAFE", Color(0.56, 0.88, 0.69)],
		["HULL", "INTACT", Color(0.56, 0.88, 0.69)],
		["ATTOM", "REBOOTED", Color(0.56, 0.88, 0.69)],
		["CLEARANCE", "CONDITIONAL", Color(0.94, 0.76, 0.42)],
	]
	for i in rows.size():
		var y := 150 + i * 48
		draw_string(font, Vector2(36, y), rows[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.5, 0.66, 0.74))
		draw_string(font, Vector2(280, y), rows[i][1], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, rows[i][2])
	draw_string(font, Vector2(36, size_px.y - 28), "FORWARD OPTICAL    JUPITER TRAFFIC LANE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.32, 0.48, 0.56))
