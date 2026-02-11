extends Node2D

@onready var health_ui := $UI/HealthUI
@onready var rewind_ui := $UI/RewindUI
@onready var player := $Player
@onready var rewind_cooldown_timer := $Player/RewindCooldownTimer
@onready var background := $Background
var rewind_cooldown_percentage := 1.0

 # INFO: Variable for the lives the player has remaining, with an accompanying set function which updates the UI
var lives := 3:
	set(value):
		lives = value
		health_ui.init_lives(lives)
@export var default_lives := 3


 # INFO: Function run only once when the game starts running
func _ready():
	lives = default_lives
	pass


 # INFO: functions for taking damage with collision (now unused)
#func _on_mini_boss_body_entered(body: Node2D) -> void:
	#if body.has_method("lose_life") and body is Player:
		#body.lose_life()
#
#
#func _on_melee_enemy_body_entered(body: Node2D) -> void:
	#if body.has_method("lose_life") and body is Player:
		#body.lose_life()
#
#
#func _on_ranged_enemy_body_entered(body: Node2D) -> void:
	#if body.has_method("lose_life") and body is Player:
		#body.lose_life()


func game_over() -> void:
	pass


func _physics_process(delta: float) -> void:
	rewind_ui.fill_rewind_bar(player.rewind_data_length()/2)
	rewind_cooldown_percentage = (1 - rewind_cooldown_timer.time_left/rewind_cooldown_timer.wait_time)
	if rewind_cooldown_percentage != 1:
		rewind_ui.modulate = Color(1.0, 1.0, 1.0, rewind_cooldown_percentage/2)
	else:
		rewind_ui.modulate = Color(1.0, 1.0, 1.0, 1.0)


func pause_enemies(pause:=true) -> void:
	for i in get_tree().get_nodes_in_group("enemies"):
		i.paused = pause
	for i in get_tree().get_nodes_in_group("enemy_attack"):
		i.paused = pause
	if pause:
		background.scroll_speed = 0
	else:
		background.reset_scroll_speed()
	
