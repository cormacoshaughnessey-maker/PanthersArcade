extends CharacterBody2D

@export var speed := 300.0

var rewind_data : Dictionary[String, Array] = {"position":[]}
var max_rewind_length := 100
var rewind_on_cooldown := false
var rewinding := false

@onready var rewind_cooldown_timer := $RewindCooldownTimer


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
	else:
		start_rewind_cooldown()

 # INFO: Begin the cooldown on rewinding, and set rewind_on_cooldown to true
func start_rewind_cooldown() -> void:
	rewinding = false
	rewind_on_cooldown = true
	rewind_cooldown_timer.start()
	# TODO: Put a cooldown for when rewind becomes usable again

 # INFO: End of the cooldown on rewinding, sets rewind_on_cooldown to false
func _finish_rewind_cooldown() -> void:
	rewind_on_cooldown = false
#endregion


#region Debug/Testing Functions
 # INFO: Quick functino for moving around, so that rewinding can be tested
func input_tests(delta: float) -> void:
	var movement_vector = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = movement_vector * speed
	move_and_slide()
	pass
#endregion
