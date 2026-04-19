extends Node2D

var car_positions = [150.0, 400.0, 700.0]
var car_speeds = [30.0, -45.0, 25.0]
var car_colors = [Color(0.8, 0.2, 0.2), Color(0.2, 0.4, 0.8), Color(0.9, 0.85, 0.2)]

func _ready() -> void:
	z_index = -10

func _process(delta: float) -> void:
	for i in car_positions.size():
		car_positions[i] += car_speeds[i] * delta
		if car_positions[i] > 1100: car_positions[i] = -80
		if car_positions[i] < -100: car_positions[i] = 1000
	queue_redraw()

func _draw() -> void:
	# === SKY ===
	draw_rect(Rect2(-500, -200, 2000, 350), Color(0.47, 0.77, 0.94))
	# Sky gradient (lighter at bottom)
	draw_rect(Rect2(-500, -20, 2000, 160), Color(0.53, 0.81, 0.98))
	
	# Sun
	draw_circle(Vector2(750, -100), 25, Color(1, 0.95, 0.6))
	draw_circle(Vector2(750, -100), 20, Color(1, 0.97, 0.7))
	
	# Clouds
	_draw_cloud(Vector2(80, -130), 0.9)
	_draw_cloud(Vector2(320, -150), 0.6)
	_draw_cloud(Vector2(550, -120), 1.1)
	_draw_cloud(Vector2(850, -140), 0.8)
	
	# === BACK BUILDINGS (far) ===
	var back_buildings = [
		[0, 45, 120], [50, 55, 145], [115, 40, 110], [165, 50, 135],
		[225, 35, 100], [275, 60, 155], [345, 42, 115], [400, 52, 140],
		[460, 38, 105], [515, 55, 150], [580, 44, 125], [635, 48, 130],
		[695, 40, 110], [745, 52, 140], [810, 38, 105], [860, 56, 148],
		[920, 42, 115], [970, 50, 130]
	]
	for b in back_buildings:
		var c = 0.35 + randf() * 0.08
		draw_rect(Rect2(b[0], 140 - b[2], b[1], b[2] + 60), Color(c, c, c + 0.02))
	
	# === FOREGROUND BUILDINGS ===
	var fg_buildings = [
		[15, 50, 130, 0.62], [80, 58, 155, 0.66], [155, 42, 115, 0.60],
		[215, 55, 145, 0.64], [285, 48, 125, 0.61], [350, 60, 160, 0.65],
		[425, 44, 118, 0.62], [485, 52, 140, 0.63], [555, 46, 122, 0.61],
		[620, 56, 148, 0.64], [695, 42, 112, 0.60], [755, 54, 142, 0.63],
		[825, 48, 128, 0.62], [890, 56, 152, 0.65], [960, 44, 118, 0.61]
	]
	for b in fg_buildings:
		var base = Color(b[3], b[3] - 0.02, b[3] - 0.04)
		draw_rect(Rect2(b[0], 140 - b[2], b[1], b[2] + 60), base)
		# Roof detail
		draw_rect(Rect2(b[0], 140 - b[2] - 4, b[1], 6), base.darkened(0.15))
		# Windows
		var win_w = 6
		var win_h = 8
		for wy in range(140 - b[2] + 10, 140, 16):
			for wx in range(b[0] + 6, b[0] + b[1] - 10, 12):
				var lit = randf() > 0.35
				var win_color = Color(0.9, 0.85, 0.55) if lit else Color(0.25, 0.25, 0.3)
				draw_rect(Rect2(wx, wy, win_w, win_h), win_color)
				if lit:
					draw_rect(Rect2(wx, wy, win_w, 1), Color(1, 0.95, 0.7))
	
	# === TREES ===
	_draw_tree(130, 140)
	_draw_tree(380, 140)
	_draw_tree(550, 140)
	_draw_tree(780, 140)
	_draw_tree(950, 140)
	
	# === STREET LAMPS ===
	_draw_lamp(200, 140)
	_draw_lamp(500, 140)
	_draw_lamp(800, 140)
	
	# === SIDEWALK ===
	draw_rect(Rect2(-500, 140, 2000, 12), Color(0.72, 0.70, 0.67))
	# Sidewalk tiles
	for x in range(-500, 1500, 24):
		draw_rect(Rect2(x, 140, 1, 12), Color(0.65, 0.63, 0.60))
	draw_rect(Rect2(-500, 151, 2000, 1), Color(0.6, 0.58, 0.55))
	
	# === STREET ===
	draw_rect(Rect2(-500, 153, 2000, 47), Color(0.32, 0.32, 0.35))
	# Road center line
	for x in range(-480, 1400, 70):
		draw_rect(Rect2(x, 174, 35, 3), Color(0.95, 0.9, 0.3))
	# Road edges
	draw_rect(Rect2(-500, 153, 2000, 2), Color(0.4, 0.4, 0.42))
	draw_rect(Rect2(-500, 198, 2000, 2), Color(0.4, 0.4, 0.42))
	
	# === CARS ===
	for i in car_positions.size():
		_draw_car(car_positions[i], 178, car_colors[i], car_speeds[i] > 0)
	
	# === SIDEWALK FOREGROUND ===
	draw_rect(Rect2(-500, 200, 2000, 20), Color(0.68, 0.66, 0.63))

func _draw_cloud(pos: Vector2, s: float) -> void:
	var c = Color(1, 1, 1, 0.85)
	draw_circle(pos, 18 * s, c)
	draw_circle(pos + Vector2(18 * s, -3), 14 * s, c)
	draw_circle(pos + Vector2(-12 * s, 2), 11 * s, c)
	draw_circle(pos + Vector2(8 * s, 6), 13 * s, c)
	draw_circle(pos + Vector2(22 * s, 4), 10 * s, c)

func _draw_tree(x: float, y: float) -> void:
	# Trunk
	draw_rect(Rect2(x - 3, y - 20, 6, 22), Color(0.45, 0.3, 0.15))
	# Foliage layers
	draw_circle(Vector2(x, y - 28), 14, Color(0.2, 0.55, 0.2))
	draw_circle(Vector2(x - 8, y - 24), 11, Color(0.25, 0.6, 0.25))
	draw_circle(Vector2(x + 8, y - 24), 11, Color(0.22, 0.58, 0.22))
	draw_circle(Vector2(x, y - 36), 10, Color(0.28, 0.62, 0.28))

func _draw_lamp(x: float, y: float) -> void:
	# Pole
	draw_rect(Rect2(x - 2, y - 45, 4, 47), Color(0.3, 0.3, 0.32))
	# Arm
	draw_rect(Rect2(x - 8, y - 45, 16, 3), Color(0.3, 0.3, 0.32))
	# Lamp head
	draw_rect(Rect2(x - 6, y - 48, 12, 5), Color(0.25, 0.25, 0.28))
	# Light glow
	draw_rect(Rect2(x - 5, y - 43, 10, 3), Color(1, 0.95, 0.7))

func _draw_car(x: float, y: float, color: Color, facing_right: bool) -> void:
	# Body
	draw_rect(Rect2(x, y - 8, 40, 10), color)
	# Roof
	draw_rect(Rect2(x + 8, y - 16, 24, 8), color.darkened(0.1))
	# Windows
	draw_rect(Rect2(x + 10, y - 14, 8, 6), Color(0.6, 0.8, 0.95, 0.8))
	draw_rect(Rect2(x + 20, y - 14, 8, 6), Color(0.6, 0.8, 0.95, 0.8))
	# Wheels
	draw_circle(Vector2(x + 8, y + 2), 5, Color(0.15, 0.15, 0.15))
	draw_circle(Vector2(x + 32, y + 2), 5, Color(0.15, 0.15, 0.15))
	# Headlights
	if facing_right:
		draw_rect(Rect2(x + 38, y - 6, 3, 4), Color(1, 0.95, 0.6))
	else:
		draw_rect(Rect2(x - 1, y - 6, 3, 4), Color(1, 0.95, 0.6))
