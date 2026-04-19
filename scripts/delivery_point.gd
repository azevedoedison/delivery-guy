extends Area2D

@onready var label := $Label
var delivery_type := 0  # 0=normal, 1=fragile, 2=express

func _ready() -> void:
	add_to_group("delivery_point")
	body_entered.connect(_on_body_entered)
	delivery_type = randi() % 3
	
	match delivery_type:
		0: label.text = "Normal"
		1: label.text = "Frágil!"
		2: label.text = "Express!"

func _draw() -> void:
	# Package (brown box)
	draw_rect(Rect2(-12, -16, 24, 20), Color(0.6, 0.4, 0.2))
	# Tape
	draw_rect(Rect2(-2, -16, 4, 20), Color(0.5, 0.3, 0.15))
	draw_rect(Rect2(-12, -6, 24, 3), Color(0.5, 0.3, 0.15))
	
	# Fragile warning
	if delivery_type == 1:
		draw_rect(Rect2(-8, -20, 16, 4), Color(1, 0.2, 0.2))
	
	# Express lightning
	elif delivery_type == 2:
		draw_rect(Rect2(-2, -22, 4, 6), Color(1, 1, 0))

func _process(delta: float) -> void:
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not body.is_carrying_package:
		body.pickup_package(0.3 if delivery_type == 1 else 0.1)
		queue_free()
