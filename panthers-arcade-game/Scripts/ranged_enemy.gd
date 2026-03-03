extends Enemy

class_name RangedEnemy

# basic ranged enemy that shoots projectiles at the player
# fires 1-2 shots then goes on cooldown

@export var attack_range := 400.0  # how far away we can shoot from
@export var min_distance := 150.0  #  try to keep this much distance from player
@export var projectiles_per_cooldown := 2  # how many shots before cooldown
@export var projectile_cooldown_duration := 3.0  # seconds between shooting bursts
@export var time_between_shots := 0.7  # seconds between each shot in a burst
@export var projectile_speed := 300.0
@export var movement_randomness := 100.0  # how much random movement to add

var projectiles_fired := 0  # track how many shots we've done in this burst
var can_shoot := true
var random_offset : Vector2  # random movement direction
var random_timer := 0.0

@export var projectile_scene : PackedScene  # assign this in the editor


func _ready() -> void:
	super._ready()
	score_value = 25
	pick_random_direction()


# main loop - keep distance from player and shoot projectiles
func move_and_attack(delta: float) -> void:
	if not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = (player.global_position - global_position).normalized()

	random_timer -= delta
	if random_timer <= 0:
		pick_random_direction()
		random_timer = randf_range(1.5, 3.0)  # pick new direction every 1.5-3 seconds

	# move away if too close, toward if too far, random movement otherwise
	var move_direction : Vector2
	if distance_to_player < min_distance:
		move_direction = (-direction_to_player * 0.8 + random_offset * 0.2).normalized()
	elif distance_to_player > attack_range:
		move_direction = (direction_to_player * 0.7 + random_offset * 0.3).normalized()
	else:
		move_direction = random_offset

	position += move_direction * move_speed * delta

	# rotate sprite to face the player
	rotation = direction_to_player.angle() + deg_to_rad(90)  

	if distance_to_player <= attack_range and can_shoot:
		shoot_projectile()


func pick_random_direction() -> void:
	random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


# fire a projectile at the player
func shoot_projectile() -> void:
	if not projectile_scene:
		push_warning("no projectile scene assigned to ranged enemy!")
		return

	projectiles_fired += 1

	# spawn the projectile
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)  # add to game scene
	projectile.global_position = global_position

	# make it fly toward the player
	var direction = (player.global_position - global_position).normalized()
	if "velocity" in projectile:
		projectile.velocity = direction * projectile_speed
	elif "direction" in projectile:
		projectile.direction = direction
		projectile.speed = projectile_speed

	# TODO: play shooting sound/animation

	# check if shot enough to go on cooldown
	if projectiles_fired >= projectiles_per_cooldown:
		can_shoot = false
		projectiles_fired = 0
		start_attack_cooldown(projectile_cooldown_duration)
	else:
		# short delay between shots in the same burst
		can_shoot = false
		await get_tree().create_timer(time_between_shots).timeout
		can_shoot = true

func _on_attack_cooldown_timeout() -> void:
	super._on_attack_cooldown_timeout()
	can_shoot = true
