extends Node2D

@onready var health_ui := $UI/HealthUI
@onready var rewind_ui := $UI/RewindUI
@onready var player := $Player
@onready var rewind_cooldown_timer := $Player/RewindCooldownTimer
var rewind_cooldown_percentage := 1.0

 # INFO: Variable for the lives the player has remaining, with an accompanying set function which updates the UI
var lives = 3:
	set(value):
		lives = value
		health_ui.init_lives(lives)


 # INFO: Function run only once when the game starts running
func _ready():
	lives = 3


 # INFO: functions for taking damage with collision
func _on_mini_boss_body_entered(body: Node2D) -> void:
	if body.has_method("lose_life"):
		body.lose_life()


func _on_melee_enemy_body_entered(body: Node2D) -> void:
	if body.has_method("lose_life"):
		body.lose_life()


func _on_ranged_enemy_body_entered(body: Node2D) -> void:
	if body.has_method("lose_life"):
		body.lose_life()


func game_over() -> void:
	pass


func _physics_process(delta: float) -> void:
	rewind_ui.fill_rewind_bar(player.rewind_data_length()/2)
	rewind_cooldown_percentage = (1 - rewind_cooldown_timer.time_left/rewind_cooldown_timer.wait_time)
	rewind_ui.modulate = Color(1.0, 1.0, 1.0, rewind_cooldown_percentage)
