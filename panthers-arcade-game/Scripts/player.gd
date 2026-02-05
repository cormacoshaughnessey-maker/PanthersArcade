extends CharacterBody2D

@export var speed := 300.0

@export var max_rewind_length_in_seconds := 1.5
var max_rewind_length : float
var rewind_data : Dictionary[String, Array] = {"position":[]}
var rewind_on_cooldown := false
var rewinding := false
var attack_positions : Array[Vector2]

@onready var game_node := self.get_parent()
@onready var player_attacks := game_node.get_node("PlayerAttacks")
@onready var player_projections := game_node.get_node("PlayerProjections")
@onready var rewind_cooldown_timer := $RewindCooldownTimer

var attack_scene := preload("res://scenes/rewind_attack.tscn")
var projection_scene := preload("res://Scenes/player_projection.tscn")

 # INFO: Function run every frame/tick
func _physics_process(delta: float) -> void:
	save_rewind_data(delta)
	inputs(delta)
	# NOTE: Put any other code that needs to be run every frame/tick in a function and call it here


 # INFO: Function run only once when the game starts running
func _ready() -> void:
	max_rewind_length = max_rewind_length_in_seconds * Engine.physics_ticks_per_second


 # INFO: Function that registers user input and does actions based on that
func inputs(delta: float) -> void:
	if Input.is_action_just_released("rewind"):
		start_rewind_cooldown()
	elif not rewind_on_cooldown and Input.is_action_pressed("rewind"):
		if Input.is_action_just_pressed("rewind"):
			spawn_projection_trail()
		rewind()
		rewind()
	if not rewinding:
		movement_inputs(delta)


#region Rewind Functions
 # INFO: Function that saves data to the rewind_data array
func save_rewind_data(_delta: float) -> void:
	if not rewinding:
		rewind_data["position"].append(global_position)
		if rewind_data["position"].size() > max_rewind_length:
			rewind_data["position"].pop_front()
	#print(rewind_data)
	pass


 # INFO: Function which moves the player 1 position back along the rewind_data array
func rewind() -> void:
	if not rewind_on_cooldown:
		if rewind_data["position"].size() > 0:
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
	for i in rewind_data["position"].size():
		if i % 10 == 0:
			spawn_projection(rewind_data["position"].get(i))



 # INFO: Spawn a single projection of the player; used for the path of rewinding
func spawn_projection(projection_position:Vector2) -> void:
	var projection_var = projection_scene.instantiate()
	projection_var.global_position = projection_position
	player_projections.call_deferred("add_child", projection_var)


 # INFO: Begin the cooldown on rewinding, and set rewind_on_cooldown to true
func start_rewind_cooldown() -> void:
	rewinding = false
	rewind_on_cooldown = true
	rewind_cooldown_timer.start()
	get_tree().call_group("player_projections", "queue_free")
	rewind_attacks()


 # INFO: End of the cooldown on rewinding, sets rewind_on_cooldown to false
func _finish_rewind_cooldown() -> void:
	rewind_on_cooldown = false
#endregion


#region Movement
 # INFO: Function for left, right, up, and down movement
func movement_inputs(_delta: float) -> void:
	var movement_vector = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = movement_vector * speed
	move_and_slide()
#endregion
