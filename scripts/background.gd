extends Node2D

func _ready() -> void:
	z_index = -10

func _draw() -> void:
	# Sky gradient (light blue to white)
	draw_rect(Rect2(-500, -200, 2000, 350), Color(0.53, 0.81, 0.98))
	
	# Sun
	draw_circle(Vector2(750, -100), 30, Color(1, 0.95, 0.6))
	
	# Clouds
	_draw_cloud(Vector2(100, -120), 1.0)
	_draw_cloud(Vector2(350, -140), 0.7)
	_draw_cloud(Vector2(600, -110), 1.2)
	
	# Background buildings (darker, further away)
	_draw_building(0, -40, 40, 150, Color(0.45, 0.45, 0.5))
	_draw_building(50, -60, 50, 170, Color(0.5, 0.5, 0.55))
	_draw_building(110, -30, 35, 140, Color(0.48, 0.48, 0.52))
	_draw_building(160, -50, 45, 160, Color(0.52, 0.52, 0.58))
	_draw_building(220, -20, 30, 130, Color(0.46, 0.46, 0.5))
	_draw_building(270, -70, 55, 180, Color(0.5, 0.5, 0.55))
	_draw_building(340, -35, 40, 145, Color(0.48, 0.48, 0.52))
	_draw_building(400, -55, 50, 165, Color(0.51, 0.51, 0.56))
	_draw_building(470, -25, 38, 135, Color(0.47, 0.47, 0.52))
	_draw_building(520, -65, 48, 175, Color(0.49, 0.49, 0.54))
	_draw_building(580, -15, 35, 125, Color(0.5, 0.5, 0.55))
	_draw_building(630, -45, 42, 155, Color(0.48, 0.48, 0.53))
	_draw_building(690, -60, 52, 170, Color(0.52, 0.52, 0.57))
	_draw_building(760, -30, 38, 140, Color(0.46, 0.46, 0.51))
	_draw_building(810, -50, 46, 160, Color(0.5, 0.5, 0.55))
	_draw_building(870, -20, 40, 130, Color(0.48, 0.48, 0.53))
	
	# Foreground buildings with windows (closer, lighter)
	_draw_foreground_building(20, -80, 45, 140, Color(0.6, 0.58, 0.55))
	_draw_foreground_building(90, -100, 55, 160, Color(0.65, 0.62, 0.58))
	_draw_foreground_building(180, -70, 40, 130, Color(0.62, 0.6, 0.56))
	_draw_foreground_building(260, -110, 60, 170, Color(0.63, 0.61, 0.57))
	_draw_foreground_building(360, -85, 48, 145, Color(0.61, 0.59, 0.55))
	_draw_foreground_building(440, -95, 52, 155, Color(0.64, 0.62, 0.58))
	_draw_foreground_building(530, -75, 42, 135, Color(0.62, 0.6, 0.56))
	_draw_foreground_building(610, -90, 50, 150, Color(0.63, 0.61, 0.57))
	_draw_foreground_building(700, -105, 55, 165, Color(0.6, 0.58, 0.54))
	_draw_foreground_building(790, -80, 45, 140, Color(0.62, 0.6, 0.56))
	_draw_foreground_building(870, -100, 52, 160, Color(0.64, 0.62, 0.58))
	
	# Sidewalk
	draw_rect(Rect2(-500, 140, 2000, 15), Color(0.7, 0.68, 0.65))
	
	# Street
	draw_rect(Rect2(-500, 155, 2000, 50), Color(0.35, 0.35, 0.38))
	
	# Road markings (dashed lines)
	for x in range(-480, 1400, 80):
		draw_rect(Rect2(x, 178, 40, 4), Color(0.9, 0.9, 0.8))
	
	# Curb
	draw_rect(Rect2(-500, 148, 2000, 3), Color(0.8, 0.78, 0.75))

func _draw_cloud(x: Vector2, scale: float) -> void:
	var s = scale
	draw_circle(x, 20 * s, Color(1, 1, 1, 0.8))
	draw_circle(x + Vector2(20 * s, -5), 15 * s, Color(1, 1, 1, 0.8))
	draw_circle(x + Vector2(-15 * s, 0), 12 * s, Color(1, 1, 1, 0.8))
	draw_circle(x + Vector2(10 * s, 5), 14 * s, Color(1, 1, 1, 0.8))

func _draw_building(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(x, 140 - h + y, w, h + y), color)

func _draw_foreground_building(x: float, y: float, w: float, h: float, color: Color) -> void:
	var bx = x
	var by = 140 - h + y
	var bh = h + y
	draw_rect(Rect2(bx, by, w, bh), color)
	
	# Windows (yellow lit)
	for wy in range(by + 8, by + bh - 8, 16):
		for wx in range(bx + 5, bx + w - 8, 12):
			var lit = randf() > 0.3
			var win_color = Color(0.9, 0.85, 0.5) if lit else Color(0.3, 0.3, 0.35)
			draw_rect(Rect2(wx, wy, 6, 8), win_color)
