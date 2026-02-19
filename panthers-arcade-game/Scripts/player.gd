class_name Player extends CharacterBody2D

@export var speed := 300.0
@export var max_health := 100.0
@export var max_lives := 3
@export var invincibility_duration := 1.5  # seconds of i-frames after getting hit
@export var rewind_invincibility_duration := 1.0 # seconds of i-frames after finishing a rewind
@export var pause_on_rewind := true # Determines whether or not enemies pause while rewinding

# signals for the UI to hook into
#signal lives_changed(current_lives: int)
signal player_died

@export var max_rewind_length_in_seconds := 1.5
@export var rewind_speed := 2
var max_rewind_length : float
var rewind_data : Dictionary[String, Array] = {"position":[]}
var rewind_on_cooldown := false
var rewinding := false
var attack_positions : Array[Vector2]

var is_invincible := false  # i-frames after taking damage

@onready var game_node := self.get_parent()
@onready var player_attacks := game_node.get_node("PlayerAttacks")
@onready var player_projections := game_node.get_node("PlayerProjections")
@onready var rewind_cooldown_timer := $RewindCooldownTimer
@onready var ui = game_node.get_node("UI/HealthUI")
@onready var hitbox := $CollisionShape2D
@onready var invincibility_cooldown_timer := $InvincibilityCooldownTimer

var attack_scene := preload("res://Scenes/rewind_attack.tscn")
var projection_scene := preload("res://Scenes/player_projection.tscn")


 # INFO: Function run when the game starts
func _ready() -> void:
	add_to_group("player")
	# calculate max rewind length based on physics ticks
	max_rewind_length = max_rewind_length_in_seconds * Engine.physics_ticks_per_second * rewind_speed


 # INFO: Function run every frame/tick
func _physics_process(delta: float) -> void:
	save_rewind_data(delta)
	inputs(delta)
	# NOTE: Put any other code that needs to be run every frame/tick in a function and call it here


 # INFO: Function that registers user input and does actions based on that
func inputs(delta: float) -> void:
	if Input.is_action_just_released("rewind"):
		if rewinding:
			start_rewind_cooldown()
	elif not rewind_on_cooldown and Input.is_action_pressed("rewind"):
		if Input.is_action_just_pressed("rewind"):
			spawn_projection_trail()
			_on_invincibility_cooldown_timer_timeout()
			if pause_on_rewind:
				game_node.pause_enemies()
			rewinding = true
		for i in rewind_speed:
			if rewinding:
				rewind()
	if not rewinding:
		movement_inputs(delta)


#region Rewind Functions
 # INFO: Returns the amount of positions saved in the rewind_data array
func rewind_data_length() -> int:
	return rewind_data["position"].size()


 # INFO: Function that saves data to the rewind_data array
func save_rewind_data(_delta: float) -> void:
	if not rewinding:
		rewind_data["position"].append(global_position)
		if rewind_data_length() > max_rewind_length:
			rewind_data["position"].pop_front()
	#print(rewind_data)
	pass


 # INFO: Function which moves the player 1 position back along the rewind_data array
func rewind() -> void:
	if not rewind_on_cooldown:
		if rewind_data_length() > 0:
			#hitbox.disabled = true
			rewinding = true
			global_position = rewind_data["position"].pop_back()
			attack_positions.append(global_position)
		else:
			start_rewind_cooldown()


 # INFO: Function which spawns all the attacks from rewinding, then clears the attack_positions array
func rewind_attacks() -> void:
	for i in attack_positions:
		spawn_attack(i)
	attack_positions.clear()


 # INFO: Function which spawns an individual rewind_attack
func spawn_attack(attack_position:Vector2, _size := 1.0) -> void:
	var attack_var = attack_scene.instantiate()
	attack_var.global_position = attack_position
	player_attacks.call_deferred("add_child", attack_var)


# INFO: Spawns a trail of projections from the player along the path of rewinding
func spawn_projection_trail() -> void:
	for i in rewind_data_length():
		if i % 10 == 0:
			spawn_projection(rewind_data["position"].get(i))


 # INFO: Spawn a single projection of the player; used for the path of rewinding
func spawn_projection(projection_position:Vector2) -> void:
	var projection_var = projection_scene.instantiate()
	projection_var.global_position = projection_position
	player_projections.call_deferred("add_child", projection_var)


 # INFO: Begin the cooldown on rewinding, and set rewind_on_cooldown to true
func start_rewind_cooldown() -> void:
	if not rewind_on_cooldown:
		rewinding = false
		rewind_on_cooldown = true
		rewind_cooldown_timer.start()
		get_tree().call_group("player_projections", "queue_free")
		rewind_attacks()
		start_invincibility(true)
		game_node.pause_enemies(false)


 # INFO: End of the cooldown on rewinding, sets rewind_on_cooldown to false
func _finish_rewind_cooldown() -> void:
	rewind_on_cooldown = false
#endregion


#region Health/Damage Functions
 # INFO: Player loses a life
func lose_life(damage := 1) -> void:
	if not rewinding and not is_invincible:
		game_node.lives -= damage
		if game_node.lives <= 0:
			# game over man, game over
			player_died.emit()
			# TODO: play death animation, show game over screen
			print("player is dead! game over!")
			game_node.game_over()
		else:
			start_invincibility()
			print("lost a life! lives left: ", game_node.lives)


 # INFO: Make player invincible for a bit after getting hit
func start_invincibility(rewind_iframes := false) -> void:
	is_invincible = true
	# TODO: make sprite flash or something to show i-frames
	modulate = Color(1.0, 1.0, 1.0, 0.5)
	if not rewind_iframes:
		invincibility_cooldown_timer.start(invincibility_duration)
	else:
		invincibility_cooldown_timer.start(rewind_invincibility_duration)


 # INFO: Ending of invincibility timers
func _on_invincibility_cooldown_timer_timeout() -> void:
	is_invincible = false
	modulate = Color(1.0, 1.0, 1.0, 1)
#endregion


#region Movement
 # INFO: Function for left, right, up, and down movement
func movement_inputs(_delta: float) -> void:
	var movement_vector = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = movement_vector * speed
	move_and_slide()
#endregion
