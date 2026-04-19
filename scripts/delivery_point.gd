extends Area2D

@onready var label := $Label
var delivery_type := 0
var bounce := 0.0

func _ready() -> void:
	add_to_group("delivery_point")
	body_entered.connect(_on_body_entered)
	# Ensure collision shape is big enough
	var col = get_node_or_null("CollisionShape2D")
	if col and col.shape:
		col.shape.size = Vector2(40, 40)
	delivery_type = randi() % 3
	match delivery_type:
		0: label.text = "📦 Normal"
		1: label.text = "⚠️ Frágil!"
		2: label.text = "🏃 Express!"
	label.position = Vector2(-30, -40)

func _process(delta: float) -> void:
	bounce += delta * 3
	queue_redraw()

func _draw() -> void:
	var by = sin(bounce) * 2  # Floating animation
	
	# Shadow
	draw_rect(Rect2(-10, 2, 20, 3), Color(0, 0, 0, 0.15))
	
	# Box body
	draw_rect(Rect2(-11, -14 + by, 22, 16), Color(0.7, 0.5, 0.25))
	# Box darker side
	draw_rect(Rect2(-11, -14 + by, 8, 16), Color(0.6, 0.42, 0.2))
	
	# Tape (vertical)
	draw_rect(Rect2(-1, -14 + by, 3, 16), Color(0.55, 0.38, 0.18))
	# Tape (horizontal)
	draw_rect(Rect2(-11, -6 + by, 22, 3), Color(0.55, 0.38, 0.18))
	
	# Box lid line
	draw_rect(Rect2(-11, -14 + by, 22, 2), Color(0.5, 0.35, 0.15))
	
	# Type indicators
	if delivery_type == 1:
		# Fragile - red warning tape
		draw_rect(Rect2(-8, -17 + by, 16, 3), Color(0.9, 0.15, 0.15))
		draw_rect(Rect2(-6, -17 + by, 12, 3), Color(0.95, 0.2, 0.2))
	elif delivery_type == 2:
		# Express - lightning bolt indicator
		draw_rect(Rect2(-3, -20 + by, 6, 4), Color(1, 0.9, 0.2))
		draw_rect(Rect2(-1, -22 + by, 2, 3), Color(1, 0.9, 0.2))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not body.is_carrying_package:
		body.pickup_package(0.3 if delivery_type == 1 else 0.1)
		queue_free()
