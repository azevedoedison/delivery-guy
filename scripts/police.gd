extends CharacterBody2D

const SPEED = 60.0
var is_chasing := false
var is_stopping := false
var player_ref: Node2D = null
var facing_right := false
var walk_frame := 0.0

@onready var detection_area := $DetectionArea
@onready var stop_timer := $StopTimer

func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	stop_timer.timeout.connect(_on_stop_timeout)

func _physics_process(delta: float) -> void:
	if is_stopping:
		velocity.x = 0
	elif is_chasing and player_ref:
		var dir = sign(player_ref.global_position.x - global_position.x)
		velocity.x = dir * SPEED
		facing_right = dir > 0
		walk_frame += delta * 6
	else:
		velocity.x = SPEED * 0.5 * (-1 if facing_right else 1)
		walk_frame += delta * 4
		if global_position.x > 900: facing_right = true
		elif global_position.x < 100: facing_right = false
	
	queue_redraw()
	move_and_slide()

func _draw() -> void:
	var f = 1.0 if facing_right else -1.0
	var walking = abs(velocity.x) > 5
	var leg_anim = sin(walk_frame) * 2.5 if walking else 0
	var arm_anim = sin(walk_frame) * 2 if walking else 0
	
	# Colors
	var skin = Color(0.96, 0.76, 0.56)
	var uniform = Color(0.18, 0.22, 0.5)
	var uniform_dark = Color(0.14, 0.18, 0.42)
	var hat_color = Color(0.12, 0.15, 0.35)
	var badge = Color(1.0, 0.85, 0.2)
	var shoe = Color(0.1, 0.1, 0.12)
	
	# Shadow
	draw_rect(Rect2(-6, 10, 14, 3), Color(0, 0, 0, 0.15))
	
	# Legs
	draw_rect(Rect2(-4, 3 + leg_anim, 3, 7), uniform)
	draw_rect(Rect2(1, 3 - leg_anim, 3, 7), uniform)
	draw_rect(Rect2(-5, 8 + leg_anim, 5, 3), shoe)
	draw_rect(Rect2(0, 8 - leg_anim, 5, 3), shoe)
	
	# Body
	draw_rect(Rect2(-5, -7, 10, 11), uniform)
	draw_rect(Rect2(-5, -7, 10, 2), uniform_dark)
	# Belt
	draw_rect(Rect2(-5, 0, 10, 2), Color(0.15, 0.12, 0.1))
	# Badge
	draw_rect(Rect2(2, -5, 3, 3), badge)
	
	# Arms
	draw_rect(Rect2(-7, -6 + arm_anim, 2, 8), uniform)
	draw_rect(Rect2(5, -6 - arm_anim, 2, 8), uniform)
	draw_rect(Rect2(-7, -6 + arm_anim + 7, 2, 3), skin)
	draw_rect(Rect2(5, -6 - arm_anim + 7, 2, 3), skin)
	
	# Head
	draw_rect(Rect2(-4, -18, 8, 11), skin)
	
	# Hat
	draw_rect(Rect2(-5, -21, 10, 4), hat_color)
	draw_rect(Rect2(-6, -18, 12, 2), hat_color)
	# Hat badge
	draw_rect(Rect2(-1, -20, 2, 2), badge)
	
	# Eyes
	draw_rect(Rect2(-2 * f, -15, 2, 2), Color(0.1, 0.1, 0.1))
	draw_rect(Rect2(2 * f, -15, 2, 2), Color(0.1, 0.1, 0.1))
	
	# Serious mouth
	draw_rect(Rect2(-2, -11, 4, 1), Color(0.6, 0.35, 0.3))

func _on_detection_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		is_chasing = true
		_stop_player()

func _on_detection_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = null

func _stop_player() -> void:
	is_stopping = true
	if player_ref:
		player_ref.velocity.x = 0
		player_ref.hit_by_police()
	stop_timer.start()

func _on_stop_timeout() -> void:
	is_stopping = false
	await get_tree().create_timer(1.0).timeout
	is_chasing = false
