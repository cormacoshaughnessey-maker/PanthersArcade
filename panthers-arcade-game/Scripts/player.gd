extends CharacterBody2D

@export var speed := 300.0

var rewind_data : Dictionary[String, Array] = {"position":[]}
var max_rewind_length := 100
var rewind_on_cooldown := false
var rewinding := false
var attack_positions : Array[Vector2]

@onready var game_node := self.get_parent()
@onready var player_attacks := game_node.get_node("PlayerAttacks")
@onready var rewind_cooldown_timer := $RewindCooldownTimer

var attack_scene := preload("res://scenes/rewind_attack.tscn")


 # INFO: Function run every frame/tick
func _physics_process(delta: float) -> void:
	save_rewind_data(delta)
	inputs(delta)
	# NOTE: Put any other code that needs to be run every frame/tick in a function and call it here


 # INFO: Function that registers user input and does actions based on that
func inputs(delta: float) -> void:
	if Input.is_action_just_released("rewind"):
		start_rewind_cooldown()
	elif not rewind_on_cooldown and Input.is_action_pressed("rewind"):
		rewind()
	if not rewinding:
		movement_inputs(delta)


#region Rewind Functions
 # INFO: Function that saves data to the rewind_data array
func save_rewind_data(_delta: float) -> void:
	if not rewinding:
		rewind_data["position"].append(position)
		if rewind_data["position"].size() > max_rewind_length:
			rewind_data["position"].pop_front()
	#print(rewind_data)
	pass


 # INFO: Function which moves the player 1 position back along the rewind_data array
func rewind() -> void:
	if rewind_data["position"].size() > 0:
		rewinding = true
		position = rewind_data["position"].pop_back()
		attack_positions.append(position)
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
	#attack_var.size = size
	player_attacks.call_deferred("add_child", attack_var)


 # INFO: Begin the cooldown on rewinding, and set rewind_on_cooldown to true
func start_rewind_cooldown() -> void:
	rewinding = false
	rewind_on_cooldown = true
	rewind_cooldown_timer.start()
	rewind_attacks()


 # INFO: End of the cooldown on rewinding, sets rewind_on_cooldown to false
func _finish_rewind_cooldown() -> void:
	rewind_on_cooldown = false
#endregion


#region Movement
 # INFO: Function for left, right, up, and down movement
func movement_inputs(delta: float) -> void:
	var movement_vector = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = movement_vector * speed
	move_and_slide()
#endregion
