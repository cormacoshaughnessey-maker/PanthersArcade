extends Node2D

@onready var health_ui := $UI/HealthUI
@onready var score_ui := $UI/ScoreUI
@onready var rewind_ui := $UI/RewindUI
@onready var player := $Player
@onready var rewind_cooldown_timer := $Player/RewindCooldownTimer
@onready var background := $Background
var rewind_cooldown_percentage := 1.0

 # INFO: Variable for the lives the player has remaining, with an accompanying set function which updates the UI
var lives := 3:
	set(value):
		lives = value
		if health_ui:
			health_ui.init_lives(lives)
@export var default_lives := 3

 # INFO: Variable for score

var score := 0:
	set(value):
		score = value
		score_ui.score = score

 # INFO: Function run only once when the game starts running
func _ready():
	lives = default_lives
	score = 0
	# Spawn wave 1
	Enemy._current_wave = 1
	var melee_scene = load("res://Scenes/melee_enemy.tscn")
	for i in Enemy.WAVE_INITIAL_ENEMY_COUNT:
		var enemy = melee_scene.instantiate()
		enemy.position = Vector2(randf_range(Enemy.WAVE_SPAWN_X_MIN, Enemy.WAVE_SPAWN_X_MAX), -80.0)
		$Enemies.add_child(enemy)
		enemy.enemy_killed.connect(_on_enemy_killed)

 # Adding score when an enemy is killed

func _on_enemy_killed(score_value):
	score = score + score_value

 # TODO: Add a gameover
func game_over() -> void:
	pass


 # Fill the rewind bar, and set its transparency
func _physics_process(delta: float) -> void:
	rewind_ui.fill_rewind_bar(player.rewind_data_length()/2)
	rewind_cooldown_percentage = (1 - rewind_cooldown_timer.time_left/rewind_cooldown_timer.wait_time)
	if rewind_cooldown_percentage != 1:
		rewind_ui.modulate = Color(1.0, 1.0, 1.0, rewind_cooldown_percentage/2)
	else:
		rewind_ui.modulate = Color(1.0, 1.0, 1.0, 1.0)


func pause_enemies(pause:=true) -> void:
	for i in get_tree().get_nodes_in_group("pausable"):
		i.pause(pause)
