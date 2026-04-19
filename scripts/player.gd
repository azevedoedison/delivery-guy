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
var blink_timer := 0.0
var is_blinking := false

@onready var delivery_area := $DeliveryArea

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	blink_timer += delta
	if blink_timer > 3.0:
		is_blinking = true
		if blink_timer > 3.15:
			is_blinking = false
			blink_timer = 0.0
	
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
	var f = 1.0 if facing_right else -1.0
	var walking = abs(velocity.x) > 10
	var leg_anim = sin(walk_frame) * 3 if walking else 0
	var arm_anim = sin(walk_frame) * 2.5 if walking else 0
	
	# Colors
	var skin = Color(0.96, 0.76, 0.56)
	var shirt = Color(1.0, 0.85, 0.1)  # Yellow uniform
	var shirt_dark = Color(0.85, 0.72, 0.08)
	var pants = Color(0.22, 0.22, 0.4)
	var pants_dark = Color(0.18, 0.18, 0.35)
	var shoe = Color(0.25, 0.15, 0.1)
	var hair = Color(0.12, 0.08, 0.05)
	var eye_white = Color(1, 1, 1)
	var eye_pupil = Color(0.1, 0.1, 0.1)
	
	# === SHADOW ===
	draw_rect(Rect2(-6, 10, 14, 3), Color(0, 0, 0, 0.15))
	
	# === LEGS ===
	var leg_y = 2
	# Left leg
	draw_rect(Rect2(-5, leg_y + leg_anim, 4, 8), pants)
	draw_rect(Rect2(-5, leg_y + leg_anim + 7, 5, 3), shoe)
	# Right leg  
	draw_rect(Rect2(1, leg_y - leg_anim, 4, 8), pants)
	draw_rect(Rect2(1, leg_y - leg_anim + 7, 5, 3), shoe)
	# Pants detail
	draw_rect(Rect2(-5, leg_y, 4, 2), pants_dark)
	draw_rect(Rect2(1, leg_y, 4, 2), pants_dark)
	
	# === BODY ===
	draw_rect(Rect2(-6, -8, 12, 11), shirt)
	# Shirt details
	draw_rect(Rect2(-6, -8, 12, 2), shirt_dark)  # Shadow at top
	draw_rect(Rect2(-1, -7, 2, 9), shirt_dark)   # Middle line
	# Collar
	draw_rect(Rect2(-2, -9, 4, 2), skin)
	
	# === ARMS ===
	var arm_y = -7
	# Left arm
	draw_rect(Rect2(-8, arm_y + arm_anim, 3, 9), shirt)
	draw_rect(Rect2(-8, arm_y + arm_anim + 8, 3, 4), skin)
	# Right arm
	draw_rect(Rect2(5, arm_y - arm_anim, 3, 9), shirt)
	draw_rect(Rect2(5, arm_y - arm_anim + 8, 3, 4), skin)
	
	# === HEAD ===
	# Face
	draw_rect(Rect2(-5, -20, 10, 12), skin)
	# Hair (top)
	draw_rect(Rect2(-5, -22, 10, 4), hair)
	# Hair (sides)
	draw_rect(Rect2(-6, -21, 2, 6), hair)
	draw_rect(Rect2(4, -21, 2, 6), hair)
	
	# Eyes
	if not is_blinking:
		draw_rect(Rect2(-3 * f, -17, 3, 3), eye_white)
		draw_rect(Rect2(-2 * f, -17, 2, 2), eye_pupil)
		draw_rect(Rect2(1 * f, -17, 3, 3), eye_white)
		draw_rect(Rect2(2 * f, -17, 2, 2), eye_pupil)
	else:
		draw_rect(Rect2(-3 * f, -16, 3, 1), eye_pupil)
		draw_rect(Rect2(1 * f, -16, 3, 1), eye_pupil)
	
	# Mouth (smile)
	draw_rect(Rect2(-2, -13, 4, 1), Color(0.7, 0.4, 0.35))
	
	# === PACKAGE on back ===
	if is_carrying_package:
		var px = -9 * f
		draw_rect(Rect2(px, -18, 8, 8), Color(0.65, 0.45, 0.2))
		draw_rect(Rect2(px + 3, -18, 2, 8), Color(0.55, 0.35, 0.15))
		draw_rect(Rect2(px, -14, 8, 2), Color(0.55, 0.35, 0.15))

func _can_deliver() -> bool:
	# Check for delivery zone (portaria)
	for area in delivery_area.get_overlapping_areas():
		if area.is_in_group("delivery_zone"):
			return true
	# Also check parent for delivery zones
	for child in get_parent().get_children():
		if child.is_in_group("delivery_zone"):
			if child.can_deliver_to(self):
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
			get_tree().call_group("ui", "show_message", "Documento ok!")

func take_damage() -> void:
	health -= 1
	get_tree().call_group("ui", "update_health", health)
	if health <= 0:
		get_tree().call_group("game", "game_over", "morto")
