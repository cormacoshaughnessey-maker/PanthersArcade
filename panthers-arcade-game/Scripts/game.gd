extends Node2D

@onready var health_ui := $UI/HealthUI
@onready var score_ui := $UI/ScoreUI
@onready var rewind_ui := $UI/RewindUI
@onready var high_score_game_over := $UI/HighScore
@onready var high_score_display := $UI/HighScoreDisplay
@onready var player := $Player
@onready var rewind_cooldown_timer := $Player/RewindCooldownTimer
@onready var background := $Background
@onready var score_multiplier_timer := $ScoreMultiplierTimer
@onready var background_music := $Sounds/BackgroundMusic
@onready var enemy_death := $Sounds/EnemyDeath
@onready var rewind_color_rect := $UI/RewindColorRect

var rewind_cooldown_percentage := 1.0
var max_rewind_bars := 131

var min_score_multiplier := 1.0
var score_multiplier_increment := 0.2
var max_score_multiplier := 2.0
var score_multiplier := min_score_multiplier
var is_game_over := false

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
func _ready() -> void:
	lives = default_lives
	score = 0
	high_score_game_over.visible = false
	high_score_display.visible = false
	load_scores()
	# Spawn wave 1
	Enemy._current_wave = 1
	var melee_scene = load("res://Scenes/melee_enemy.tscn")
	for i in Enemy.WAVE_INITIAL_ENEMY_COUNT:
		var enemy = melee_scene.instantiate()
		enemy.position = Vector2(randf_range(Enemy.WAVE_SPAWN_X_MIN, Enemy.WAVE_SPAWN_X_MAX), -80.0)
		_connect_enemy_signals(enemy)
		$Enemies.add_child(enemy)


func _connect_enemy_signals(enemy: Enemy) -> void:
	enemy.enemy_killed.connect(_on_enemy_killed)
	enemy.tree_exited.connect(_on_enemy_removed)


func _spawn_wave() -> void:
	var canvas_transform = get_canvas_transform()
	var screen_top_y = -canvas_transform.origin.y
	var spawn_y = screen_top_y + Enemy.WAVE_SPAWN_Y_OFFSET

	var enemy_count = mini(Enemy.WAVE_INITIAL_ENEMY_COUNT + Enemy._current_wave - 1, Enemy.WAVE_MAX_ENEMY_COUNT)

	var melee_scene = load("res://Scenes/melee_enemy.tscn")
	var ranged_scene = load("res://Scenes/ranged_enemy.tscn")

	for i in enemy_count:
		var enemy_scene: PackedScene
		if Enemy._current_wave <= 2:
			enemy_scene = melee_scene
		else:
			enemy_scene = melee_scene if randf() > 0.5 else ranged_scene

		var enemy = enemy_scene.instantiate()
		var spawn_x = randf_range(Enemy.WAVE_SPAWN_X_MIN, Enemy.WAVE_SPAWN_X_MAX)
		enemy.position = Vector2(spawn_x, spawn_y + randf_range(-30.0, 30.0))
		_connect_enemy_signals(enemy)
		$Enemies.call_deferred("add_child", enemy)

	if Enemy._current_wave % Enemy.WAVE_MINI_BOSS_EVERY == 0:
		var boss_scene = load("res://Scenes/mini_boss.tscn")
		var boss = boss_scene.instantiate()
		boss.position = Vector2((Enemy.WAVE_SPAWN_X_MIN + Enemy.WAVE_SPAWN_X_MAX) / 2.0, spawn_y - 50.0)
		_connect_enemy_signals(boss)
		$Enemies.call_deferred("add_child", boss)


func _on_enemy_killed(score_value) -> void:
	score = score + score_value*score_multiplier
	score_multiplier = snappedf(score_multiplier + score_multiplier_increment, score_multiplier_increment)
	score_multiplier = minf(score_multiplier, max_score_multiplier)
	score_multiplier_timer.start()
	color_multiplier_bar()
	enemy_death.play()


func _on_score_multiplier_timer_timeout() -> void:
	score_multiplier = min_score_multiplier
	pass # Replace with function body.


func _on_enemy_removed() -> void:
	if is_game_over or !is_inside_tree():
		return
	if get_tree().get_node_count_in_group("enemies") > 0:
		return
	#for e in get_tree().get_nodes_in_group("enemies"):
		#if e is Enemy and e.is_inside_tree():
			#return
	Enemy._current_wave += 1
	_spawn_wave()


func game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	for i in get_tree().get_nodes_in_group("enemies"):
		i.set_physics_process(false)
		if i.attack_sound:
			i.attack_sound.stop()
		if i.attack_sound_2:
			i.attack_sound_2.stop()
		i.queue_free()
	for i in get_tree().get_nodes_in_group("enemy_attack"):
		i.queue_free()
	player.set_physics_process(false)
	high_score_game_over.visible = true


 # Fill the rewind bar, and set its transparency
func _physics_process(_delta: float) -> void:
	rewind_ui.fill_rewind_bar(player.rewind_data_length()/player.max_rewind_length * max_rewind_bars)
	rewind_cooldown_percentage = (1 - rewind_cooldown_timer.time_left/rewind_cooldown_timer.wait_time)
	if rewind_cooldown_percentage != 1:
		rewind_ui.modulate = Color(1.0, 1.0, 1.0, rewind_cooldown_percentage/2)
	else:
		rewind_ui.modulate = Color(1.0, 1.0, 1.0, 1.0)
	fill_multiplier_bar(score_multiplier_timer.time_left)
	rewind_color_rect.visible = player.rewinding


func fill_multiplier_bar(time_left) -> void:
	score_ui.fill_cooldown_bar(time_left, score_multiplier)
	color_multiplier_bar()


func color_multiplier_bar() -> void:
	score_ui.color_multiplier_bar(score_multiplier)

func pause_enemies(pause:=true) -> void:
	for i in get_tree().get_nodes_in_group("pausable"):
		i.pause(pause)

#save_score() is called when the player dies and the game is over
#load_scores() is called in the _ready() function
var high_score_list : Dictionary
var high_score_player : String
#These are two missing variables
#region Save and Load
func save_score() -> void:
	#if score>high_score:
		#high_score_player = player_name
		#high_score = score
	save_game()


func load_scores() -> void:
	load_game()


func save() -> Dictionary:
	if high_score_list.get_or_add(high_score_game_over.player_name,0) <= score_ui.score:
		high_score_list[high_score_game_over.player_name] = score_ui.score
	var save_dict := high_score_list
	return save_dict


func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var node_data = self.call("save")
		# # JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data)
		# # Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)


func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.data
		#high_score = 0
		for i in node_data.keys():
			high_score_list[i] = node_data[i]
			#if high_score_list[i]>high_score:
				#high_score_player = i
				#high_score = high_score_list[i]
		print(high_score_list)


#func _exit_tree() -> void:
	#save_score()
