extends Area2D

@onready var label := $Label
@onready var sprite := $Sprite2D
@onready var package := $Package

var is_occupied := false

func _ready() -> void:
	add_to_group("delivery_point")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Random delivery type
	var types = ["📦 Normal", "⚠️ Frágil", "🏃 Express"]
	label.text = types[randi() % types.size()]

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not body.is_carrying_package:
			body.pickup_package(0.3 if "Frágil" in label.text else 0.1)
			package.visible = false
			label.text = "Entregue na portaria →"

func _on_body_exited(body: Node2D) -> void:
	pass

func deliver() -> void:
	queue_free()
