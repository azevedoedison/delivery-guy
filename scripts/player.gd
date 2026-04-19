extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -280.0
const GRAVITY = 600.0

var is_carrying_package := false
var package_weight := 0.0
var crimes := 0
var has_license := true
var money := 0
var health := 3
var facing_right := true
var is_delivering := false
var walk_frame := 0.0

@onready var delivery_area := $DeliveryArea

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED * (1.0 - package_weight * 0.2)
		facing_right = direction > 0
		walk_frame += delta * 8
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.3)
		walk_frame = 0

	if Input.is_action_just_pressed("deliver") and is_carrying_package and _can_deliver():
		_perform_delivery()

	queue_redraw()
	move_and_slide()

func _draw() -> void:
	var flip = -1.0 if facing_right else 1.0
	
	# Player body (yellow shirt guy)
	var body_color = Color(1, 0.85, 0.1)  # Yellow uniform
	var skin_color = Color(0.95, 0.75, 0.55)
	var pants_color = Color(0.2, 0.2, 0.4)
	var hair_color = Color(0.15, 0.1, 0.05)
	
	# Head
	draw_rect(Rect2(-4, -18, 8, 8), skin_color)
	# Hair
	draw_rect(Rect2(-4, -20, 8, 4), hair_color)
	# Eyes
	draw_rect(Rect2(-2 + 3 * flip, -16, 2, 2), Color.BLACK)
	
	# Body
	draw_rect(Rect2(-5, -10, 10, 10), body_color)
	
	# Arms animation
	var arm_y = sin(walk_frame) * 3 if abs(velocity.x) > 10 else 0
	draw_rect(Rect2(-7, -9 + arm_y, 3, 8), skin_color)
	draw_rect(Rect2(4, -9 - arm_y, 3, 8), skin_color)
	
	# Legs animation
	var leg_offset = sin(walk_frame) * 4 if abs(velocity.x) > 10 else 0
	draw_rect(Rect2(-4, 0, 3, 8 + leg_offset), pants_color)
	draw_rect(Rect2(1, 0, 3, 8 - leg_offset), pants_color)
	
	# Shoes
	draw_rect(Rect2(-5, 6 + leg_offset, 5, 3), Color(0.3, 0.2, 0.1))
	draw_rect(Rect2(0, 6 - leg_offset, 5, 3), Color(0.3, 0.2, 0.1))
	
	# Package on back if carrying
	if is_carrying_package:
		draw_rect(Rect2(-8 * flip, -16, 8, 8), Color(0.6, 0.4, 0.2))
		draw_rect(Rect2(-8 * flip, -16, 8, 2), Color(0.5, 0.3, 0.15))

func _can_deliver() -> bool:
	for area in delivery_area.get_overlapping_areas():
		if area.is_in_group("delivery_point"):
			return true
	return false

func _perform_delivery() -> void:
	is_delivering = true
	var reward = 10 + randi() % 20
	money += reward
	is_carrying_package = false
	package_weight = 0.0
	
	get_tree().call_group("ui", "update_money", money)
	get_tree().call_group("ui", "show_message", "Entrega! +R$" + str(reward))
	
	# Remove the delivery point
	for area in delivery_area.get_overlapping_areas():
		if area.is_in_group("delivery_point"):
			area.queue_free()
	
	var gm = get_parent()
	if gm.has_method("check_level_complete"):
		gm.check_level_complete()
	
	is_delivering = false

func pickup_package(weight: float) -> void:
	is_carrying_package = true
	package_weight = weight
	get_tree().call_group("ui", "show_message", "Pegue a encomenda!")

func add_crime() -> void:
	crimes += 1
	get_tree().call_group("ui", "update_crimes", crimes)
	if crimes >= 3:
		has_license = false
		get_tree().call_group("ui", "show_message", "CARTEIRA SUSPENSA!")
	else:
		get_tree().call_group("ui", "show_message", "Infracao! " + str(crimes) + "/3")

func hit_by_police() -> void:
	if not has_license:
		get_tree().call_group("game", "game_over", "preso")
	else:
		var prev = crimes
		crimes = 0
		get_tree().call_group("ui", "update_crimes", crimes)
		if prev > 0:
			get_tree().call_group("ui", "show_message", "Documento ok, crimes resetados!")

func take_damage() -> void:
	health -= 1
	get_tree().call_group("ui", "update_health", health)
	if health <= 0:
		get_tree().call_group("game", "game_over", "morto")
