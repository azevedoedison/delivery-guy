extends Node2D

var current_level := 1
var total_levels := 30
var time_remaining := 120.0
var is_game_active := false

@onready var player := $Player
@onready var ui := $UI
@onready var camera := $Player/Camera2D
@onready var level_timer := $LevelTimer

func _ready() -> void:
	start_level(current_level)

func _process(delta: float) -> void:
	if is_game_active:
		time_remaining -= delta
		ui.update_time(time_remaining)
		
		if time_remaining <= 0:
			game_over("tempo")

func start_level(level: int) -> void:
	current_level = level
	is_game_active = true
	time_remaining = 60.0 + (level * 5)  # More time for harder levels
	
	ui.show_level(current_level)
	ui.update_time(time_remaining)
	ui.update_money(player.money)
	ui.update_health(player.health)
	ui.update_crimes(player.crimes)
	
	# Spawn deliveries based on level
	_spawn_deliveries(level)

func _spawn_deliveries(level: int) -> void:
	# Levels 1-5: 1 delivery at a time
	# Levels 6-15: 2 deliveries
	# Levels 16+: 3 deliveries
	var count = 1
	if level >= 16:
		count = 3
	elif level >= 6:
		count = 2
	
	for i in count:
		var delivery_point = preload("res://scenes/delivery_point.tscn").instantiate()
		delivery_point.position = Vector2(200 + randi() % 600, 130)
		add_child(delivery_point)

func level_complete() -> void:
	is_game_active = false
	
	var bonus = int(time_remaining) * 2
	player.money += bonus
	
	ui.show_level_complete(current_level, bonus)
	
	# Wait for player to continue
	await get_tree().create_timer(2.0).timeout
	
	if current_level < total_levels:
		start_level(current_level + 1)
	else:
		game_complete()

func game_over(reason: String) -> void:
	is_game_active = false
	
	var message = ""
	match reason:
		"tempo":
			message = "TEMPO ESGOTADO!"
		"preso":
			message = "VOCÊ FOI PRESO!"
		"morto":
			message = "VOCÊ MORREU!"
	
	ui.show_game_over(message, player.money, current_level)

func game_complete() -> void:
	is_game_active = false
	
	var ending = "bom"
	if player.money >= 15000:
		ending = "perfeito"
	elif player.money < 10000:
		ending = "triste"
	
	ui.show_ending(ending, player.money)

func restart_game() -> void:
	player.money = 0
	player.health = 3
	player.crimes = 0
	player.has_license = true
	start_level(1)
