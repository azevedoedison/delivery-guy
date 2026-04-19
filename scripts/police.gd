extends CharacterBody2D

const SPEED = 80.0
var is_chasing := false
var is_stopping := false
var player_ref: Node2D = null

@onready var sprite := $Sprite2D
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
		var direction = sign(player_ref.global_position.x - global_position.x)
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
	else:
		# Patrol back and forth
		velocity.x = SPEED * 0.5 * (-1 if sprite.flip_h else 1)
		if abs(global_position.x) > 800:
			sprite.flip_h = not sprite.flip_h
	
	move_and_slide()

func _on_detection_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		_stop_player()

func _on_detection_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = null

func _stop_player() -> void:
	is_stopping = true
	player_ref.velocity.x = 0
	
	# Police talks to player
	player_ref.hit_by_police()
	
	stop_timer.start()

func _on_stop_timeout() -> void:
	is_stopping = false
	# Resume patrol after a moment
	await get_tree().create_timer(1.0).timeout
	is_chasing = false
