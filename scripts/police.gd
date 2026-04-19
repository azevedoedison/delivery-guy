extends CharacterBody2D

const SPEED = 60.0
var is_chasing := false
var is_stopping := false
var player_ref: Node2D = null
var facing_right := false

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
	else:
		# Patrol
		velocity.x = SPEED * 0.5 * (-1 if facing_right else 1)
		if global_position.x > 900:
			facing_right = true
		elif global_position.x < 100:
			facing_right = false
	
	queue_redraw()
	move_and_slide()

func _draw() -> void:
	var flip = -1.0 if facing_right else 1.0
	
	# Police body (blue uniform)
	var body_color = Color(0.15, 0.2, 0.5)  # Dark blue
	var skin_color = Color(0.95, 0.75, 0.55)
	var hat_color = Color(0.1, 0.1, 0.3)
	
	# Hat
	draw_rect(Rect2(-5, -22, 10, 4), hat_color)
	draw_rect(Rect2(-6, -19, 12, 2), hat_color)
	
	# Head
	draw_rect(Rect2(-4, -18, 8, 8), skin_color)
	# Eyes
	draw_rect(Rect2(-2 + 3 * flip, -16, 2, 2), Color.BLACK)
	
	# Body (blue uniform)
	draw_rect(Rect2(-5, -10, 10, 10), body_color)
	# Badge
	draw_rect(Rect2(1, -8, 3, 3), Color(1, 0.85, 0.2))
	
	# Arms
	draw_rect(Rect2(-7, -9, 3, 7), body_color)
	draw_rect(Rect2(4, -9, 3, 7), body_color)
	
	# Legs
	draw_rect(Rect2(-4, 0, 3, 8), body_color)
	draw_rect(Rect2(1, 0, 3, 8), body_color)
	
	# Shoes
	draw_rect(Rect2(-5, 6, 5, 3), Color.BLACK)
	draw_rect(Rect2(0, 6, 5, 3), Color.BLACK)

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
