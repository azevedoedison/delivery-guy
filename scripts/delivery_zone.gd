extends Area2D

# This is the "portaria" - the delivery destination
var player_near := false

func _ready() -> void:
	add_to_group("delivery_zone")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _draw() -> void:
	# Portaria building (lighter color, prominent)
	draw_rect(Rect2(-20, -60, 40, 70), Color(0.85, 0.82, 0.78))
	
	# Door
	draw_rect(Rect2(-8, -10, 16, 20), Color(0.5, 0.35, 0.2))
	# Door handle
	draw_rect(Rect2(4, -2, 2, 4), Color(0.8, 0.7, 0.2))
	
	# Windows
	draw_rect(Rect2(-16, -50, 10, 10), Color(0.6, 0.8, 0.95))
	draw_rect(Rect2(6, -50, 10, 10), Color(0.6, 0.8, 0.95))
	
	# Roof
	draw_rect(Rect2(-24, -65, 48, 7), Color(0.4, 0.3, 0.25))
	
	# Sign
	draw_rect(Rect2(-15, -72, 30, 8), Color(0.95, 0.9, 0.8))
	
	# Pulsing highlight when player is near
	if player_near:
		draw_rect(Rect2(-22, -67, 44, 78), Color(0.2, 1, 0.3, 0.3))
		draw_rect(Rect2(-22, -67, 44, 78), Color(0.2, 1, 0.3, 0.5), false, 2)

func _process(delta: float) -> void:
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true
		if body.is_carrying_package:
			get_tree().call_group("ui", "show_message", "Aperte S para entregar!")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false

func can_deliver_to(player: Node2D) -> bool:
	return player_near and player.is_carrying_package
