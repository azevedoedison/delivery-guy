extends CanvasLayer

@onready var money_label := $HUD/MoneyLabel
@onready var time_label := $HUD/TimeLabel
@onready var health_label := $HUD/HealthLabel
@onready var crime_label := $HUD/CrimeLabel
@onready var level_label := $HUD/LevelLabel
@onready var message_label := $HUD/MessageLabel
@onready var message_timer := $HUD/MessageTimer

@onready var screens := $Screens
@onready var title_screen := $Screens/TitleScreen
@onready var select_screen := $Screens/SelectScreen
@onready var game_over_screen := $Screens/GameOverScreen
@onready var level_complete_screen := $Screens/LevelCompleteScreen

# Selected company
var selected_company := ""

func _ready() -> void:
	show_title()
	message_timer.timeout.connect(_hide_message)

# === HUD Updates ===

func update_money(amount: int) -> void:
	money_label.text = "R$" + str(amount)

func update_time(seconds: float) -> void:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	time_label.text = "%02d:%02d" % [mins, secs]
	
	if seconds < 30:
		time_label.add_theme_color_override("font_color", Color.RED)
	else:
		time_label.add_theme_color_override("font_color", Color.WHITE)

func update_health(health: int) -> void:
	health_label.text = ""
	for i in health:
		health_label.text += "❤️"

func update_crimes(crimes: int) -> void:
	crime_label.text = "🚨" + str(crimes) + "/3"
	if crimes >= 2:
		crime_label.add_theme_color_override("font_color", Color.RED)
	elif crimes >= 1:
		crime_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		crime_label.add_theme_color_override("font_color", Color.WHITE)

func show_level(level: int) -> void:
	level_label.text = "Fase " + str(level) + "/30"

func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	message_timer.start()

func _hide_message() -> void:
	message_label.visible = false

# === Screens ===

func show_title() -> void:
	_hide_all_screens()
	title_screen.visible = true

func show_select() -> void:
	_hide_all_screens()
	select_screen.visible = true

func show_level_complete(level: int, bonus: int) -> void:
	_hide_all_screens()
	level_complete_screen.visible = true
	level_complete_screen.get_node("Label").text = "FASE " + str(level) + " COMPLETA!"
	level_complete_screen.get_node("BonusLabel").text = "Bônus: R$" + str(bonus)

func show_game_over(reason: String, money: int, level: int) -> void:
	_hide_all_screens()
	game_over_screen.visible = true
	game_over_screen.get_node("ReasonLabel").text = reason
	game_over_screen.get_node("StatsLabel").text = "Dinheiro: R$" + str(money) + " | Fase: " + str(level)

func show_ending(ending: String, money: int) -> void:
	_hide_all_screens()
	var screen = game_over_screen
	screen.visible = true
	
	match ending:
		"triste":
			screen.get_node("ReasonLabel").text = "Quase conseguiu..."
			screen.get_node("StatsLabel").text = "R$" + str(money) + " — Não foi suficiente"
		"bom":
			screen.get_node("ReasonLabel").text = "CONSEGUIU! 🎉"
			screen.get_node("StatsLabel").text = "R$" + str(money) + " — A filha está curada!"
		"perfeito":
			screen.get_node("ReasonLabel").text = "ENTREGA PERFEITA! 🏆"
			screen.get_node("StatsLabel").text = "R$" + str(money) + " — Abriu sua própria delivery!"

func _hide_all_screens() -> void:
	for child in screens.get_children():
		child.visible = false

# === Button Handlers ===

func _on_play_pressed() -> void:
	show_select()

func _on_select_mercadolivre() -> void:
	selected_company = "mercado_livre"
	get_parent().start_game("mercado_livre")

func _on_select_ifood() -> void:
	selected_company = "ifood"
	get_parent().start_game("ifood")

func _on_select_shopee() -> void:
	selected_company = "shopee"
	get_parent().start_game("shopee")

func _on_restart_pressed() -> void:
	get_parent().restart_game()
