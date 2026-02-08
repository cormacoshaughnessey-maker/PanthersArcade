extends CharacterBody2D

@export var speed := 300.0
@export var max_health := 100.0
@export var max_lives := 3
@export var invincibility_duration := 1.5  # seconds of i-frames after getting hit

# signals for the UI to hook into
signal health_changed(current_health: float, max_health: float)
signal lives_changed(current_lives: int)
signal player_died

var rewind_data : Dictionary[String, Array] = {"position":[]}
var max_rewind_length := 100
var rewind_on_cooldown := false
var rewinding := false
var attack_positions : Array[Vector2]

var current_health : float
var current_lives : int
var is_invincible := false  # i-frames after taking damage

@onready var game_node := self.get_parent()
@onready var player_attacks := game_node.get_node("PlayerAttacks")
@onready var rewind_cooldown_timer := $RewindCooldownTimer

var attack_scene := preload("res://scenes/rewind_attack.tscn")


func _ready() -> void:
	add_to_group("player")
	# initialize health and lives
	current_health = max_health
	current_lives = max_lives


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
	# TODO: Put conditionals for movement inputs here
	# Make sure to check that rewinding is false first!
	# Also, be sure to use a method like move_and_slide() to make sure to account for collisions
	if not rewinding:
		input_tests(delta)


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


#region Health/Damage Functions
 # INFO: Called when player takes damage from enemies
func take_damage(amount: float) -> void:
	# can't take damage while invincible or rewinding (rewinding gives i-frames too)
	if is_invincible or rewinding:
		return

	current_health -= amount
	health_changed.emit(current_health, max_health)
	# TODO: play hurt animation/effect, maybe flash the sprite

	if current_health <= 0:
		lose_life()
	else:
		# give player some i-frames so they don't get stunlocked
		start_invincibility()


 # INFO: Player loses a life
func lose_life() -> void:
	current_lives -= 1
	lives_changed.emit(current_lives)

	if current_lives <= 0:
		# game over man, game over
		player_died.emit()
		# TODO: play death animation, show game over screen
		print("player is dead! game over!")
	else:
		# still got lives left, reset health and give i-frames
		current_health = max_health
		health_changed.emit(current_health, max_health)
		start_invincibility()
		print("lost a life! lives left: ", current_lives)


 # INFO: Make player invincible for a bit after getting hit
func start_invincibility() -> void:
	is_invincible = true
	# TODO: make sprite flash or something to show i-frames
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false
#endregion


#region Debug/Testing Functions
 # INFO: Quick function for moving around, so that rewinding can be tested
func input_tests(delta: float) -> void:
	var movement_vector = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = movement_vector * speed
	move_and_slide()
	pass
#endregion
