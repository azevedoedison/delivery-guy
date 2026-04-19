extends CharacterBody2D

# Movement constants
const SPEED = 120.0
const JUMP_VELOCITY = -280.0
const GRAVITY = 600.0

# Player state
var is_carrying_package := false
var package_weight := 0.0
var crimes := 0
var has_license := true
var money := 0
var health := 3

# Visual
var facing_right := true
var is_delivering := false

# References
@onready var sprite := $Sprite2D
@onready var delivery_area := $DeliveryArea
@onready var package_sprite := $PackageSprite

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED * (1.0 - package_weight * 0.2)
		facing_right = direction > 0
		sprite.flip_h = not facing_right
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.3)

	# Handle delivery
	if Input.is_action_just_pressed("deliver") and is_carrying_package and _can_deliver():
		_perform_delivery()

	# Simple visual feedback
	if not is_on_floor():
		sprite.scale = Vector2(0.9, 1.1) # stretch when jumping
	elif abs(velocity.x) > 10:
		# Squash and stretch while walking
		var t = fmod(Time.get_ticks_msec() * 0.01, TAU)
		sprite.scale = Vector2(1.0 + sin(t) * 0.05, 1.0 - sin(t) * 0.05)
	else:
		sprite.scale = Vector2(1, 1)

	move_and_slide()

func _can_deliver() -> bool:
	var areas = delivery_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("delivery_point"):
			return true
	return false

func _perform_delivery() -> void:
	is_delivering = true
	
	# Flash green
	sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.3).timeout
	sprite.modulate = Color(1, 0.95, 0.2, 1)
	
	# Calculate reward
	var reward = 10 + randi() % 20
	money += reward
	
	is_carrying_package = false
	package_weight = 0.0
	package_sprite.visible = false
	
	# Signal delivery complete
	get_tree().call_group("ui", "update_money", money)
	get_tree().call_group("ui", "show_message", "Entrega! +R$" + str(reward))
	
	# Check if level complete
	var gm = get_parent()
	if gm.has_method("check_level_complete"):
		gm.check_level_complete()
	
	is_delivering = false

func pickup_package(weight: float) -> void:
	is_carrying_package = true
	package_weight = weight
	package_sprite.visible = true
	get_tree().call_group("ui", "show_message", "Pegue a encomenda!")

func add_crime() -> void:
	crimes += 1
	get_tree().call_group("ui", "update_crimes", crimes)
	
	if crimes >= 3:
		has_license = false
		get_tree().call_group("ui", "show_message", "CARTEIRA SUSPENSA!")
	else:
		get_tree().call_group("ui", "show_message", "Infração! " + str(crimes) + "/3")

func hit_by_police() -> void:
	if not has_license:
		# Game over - arrested
		get_tree().call_group("game", "game_over", "preso")
	else:
		# Just showing license, reset crimes
		var prev_crimes = crimes
		crimes = 0
		get_tree().call_group("ui", "update_crimes", crimes)
		if prev_crimes > 0:
			get_tree().call_group("ui", "show_message", "Documento ok, crimes resetados!")
		else:
			get_tree().call_group("ui", "show_message", "Documento ok, pode seguir!")

func take_damage() -> void:
	health -= 1
	get_tree().call_group("ui", "update_health", health)
	
	if health <= 0:
		get_tree().call_group("game", "game_over", "morto")
	else:
		# Flash red
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		sprite.modulate = Color(1, 0.95, 0.2, 1)
