extends Node2D

var current_level := 0
var total_levels := 30
var time_remaining := 120.0
var is_game_active := false
var deliveries_completed := 0
var deliveries_needed := 1
var selected_company := ""
var delivery_scene = preload("res://scenes/delivery_point.tscn")

@onready var player: CharacterBody2D = $Player
@onready var ui: CanvasLayer = $UI
@onready var enemies_node: Node2D = $Enemies
@onready var deliveries_node: Node2D = $Deliveries

func _ready() -> void:
	player.add_to_group("player")
	ui.add_to_group("ui")
	add_to_group("game")
	ui.show_title()

func _process(delta: float) -> void:
	if is_game_active:
		time_remaining -= delta
		ui.update_time(time_remaining)
		if time_remaining <= 0:
			game_over("tempo")

func start_game(company: String) -> void:
	selected_company = company
	current_level = 1
	player.money = 0
	player.health = 3
	player.crimes = 0
	player.has_license = true
	start_level(1)

func start_level(level: int) -> void:
	current_level = level
	is_game_active = true
	time_remaining = 60.0 + (level * 5)
	deliveries_completed = 0
	deliveries_needed = 1 if level < 6 else 2 if level < 16 else 3
	
	# Clear old deliveries and enemies
	for child in deliveries_node.get_children():
		child.queue_free()
	for child in enemies_node.get_children():
		child.queue_free()
	
	# Spawn deliveries
	for i in deliveries_needed:
		var dp = delivery_scene.instantiate()
		dp.position = Vector2(300 + i * 250 + randi() % 100, 130)
		deliveries_node.add_child(dp)
	
	# Spawn police (more as levels increase)
	var police_count = min(1 + level / 5, 4)
	for i in police_count:
		var police = preload("res://scenes/police.tscn").instantiate()
		police.position = Vector2(200 + i * 300 + randi() % 100, 130)
		enemies_node.add_child(police)
	
	ui.show_level(current_level)
	ui.update_time(time_remaining)
	ui.update_money(player.money)
	ui.update_health(player.health)
	ui.update_crimes(player.crimes)

func check_level_complete() -> void:
	deliveries_completed += 1
	if deliveries_completed >= deliveries_needed:
		level_complete()

func level_complete() -> void:
	is_game_active = false
	var bonus = int(time_remaining) * 2
	player.money += bonus
	ui.show_level_complete(current_level, bonus)
	
	await get_tree().create_timer(3.0).timeout
	
	if current_level < total_levels:
		start_level(current_level + 1)
	else:
		game_complete()

func game_over(reason: String) -> void:
	is_game_active = false
	var message = ""
	match reason:
		"tempo": message = "TEMPO ESGOTADO!"
		"preso": message = "VOCE FOI PRESO!"
		"morto": message = "VOCE MORREU!"
	ui.show_game_over(message, player.money, current_level)

func game_complete() -> void:
	is_game_active = false
	var ending = "bom"
	if player.money >= 15000: ending = "perfeito"
	elif player.money < 10000: ending = "triste"
	ui.show_ending(ending, player.money)

func restart_game() -> void:
	player.money = 0
	player.health = 3
	player.crimes = 0
	player.has_license = true
	start_level(1)
