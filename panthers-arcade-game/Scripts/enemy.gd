extends Area2D

class_name Enemy

# base class for all enemies in the game

# emitted when enemy dies so game can track score
signal enemy_killed(score_value: int)

@export var max_health := 100.0
@export var move_speed := 150.0
@export var damage := 10.0
@export var score_value := 10  # how many points player gets for killing this enemy
@export var contact_damage_cooldown := 1.0  # how often contact damage can happen

var paused := false
var invulnerable := false
var current_health : float
var player : CharacterBody2D  # reference to the player so enemies can chase them
var attack_cooldown := false
var can_deal_contact_damage := true  # prevent spamming damage on contact

@onready var attack_timer : Timer = get_node_or_null("AttackCooldownTimer")


func _ready() -> void:
	current_health = max_health
	# find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	# connect the area entered signal so enemy can damage the player on collision
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	self.add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if not paused: # only move if the enemy is not paused
		# each enemy type will override this to do their own movement and attacks
		move_and_attack(delta)
		# clean up enemies that fall too far off screen
		check_if_off_screen()


# remove enemies that are way off screen so we don't waste resources
func check_if_off_screen() -> void:
	if not player:
		return
	# if enemy is way behind the player (below them in a top-down scroll), delete it
	# using 800 pixels as the buffer since that's about a screen height
	if global_position.y > player.global_position.y + 800:
		queue_free()  # bye bye, you missed your chance


# override this in child classes to make enemies have their own movements and attacks
func move_and_attack(_delta: float) -> void:
	pass


# call this when the enemy gets hit
func take_damage(amount: float) -> void:
	if not invulnerable:
		current_health -= amount
		invulnerable = true
		await get_tree().create_timer(0.5).timeout
		invulnerable = false
		# TODO: play hurt animation or effect here
	if current_health <= 0:
		die()


	


# enemy dies
func die() -> void:
	# TODO: play death animation/particle effect
	# emit signal so game can add score
	enemy_killed.emit(score_value)
	queue_free()  # remove from game


# start the attack cooldown timer
func start_attack_cooldown(cooldown_time: float) -> void:
	attack_cooldown = true
	if attack_timer:
		attack_timer.wait_time = cooldown_time
		attack_timer.start()
	else:
		# fallback if no timer node exists
		await get_tree().create_timer(cooldown_time).timeout
		_on_attack_cooldown_timeout()

# called when attack timer finishes
func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false


# when enemy touches something
func _on_area_entered(area: Area2D) -> void:
	# check if enemy hit a player attack
	if area.is_in_group("player_attack"):
		take_damage(area.damage if "damage" in area else 10)


# when enemy touches player directly
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body is Player:
		# damage the player on contact
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if body.has_method("lose_life"):
			body.lose_life()
		# brief cooldown so we don't spam damage while overlapping
		#can_deal_contact_damage = false
		#await get_tree().create_timer(contact_damage_cooldown).timeout
		#can_deal_contact_damage = true
