extends Enemy

class_name RangedEnemy

@export var attack_range := 400.0
@export var min_distance := 150.0
@export var projectiles_per_cooldown := 2
@export var projectile_cooldown_duration := 3.0
@export var time_between_shots := 0.7
@export var projectile_speed := 300.0
@export var movement_randomness := 100.0

var projectiles_fired := 0
var can_shoot := true
var random_offset : Vector2
var target_random_offset : Vector2
var random_timer := 0.0

@export var projectile_scene : PackedScene


func _ready() -> void:
	death_sprite_texture = preload("res://Assets/Sprites/enemy_death_spritesheet.png")
	death_frame_size = 128
	super._ready()
	score_value = 25
	pick_random_direction()
	random_offset = target_random_offset


func move_and_attack(delta: float) -> void:
	if not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = (player.global_position - global_position).normalized()

	random_timer -= delta
	if random_timer <= 0:
		pick_random_direction()
		random_timer = randf_range(1.5, 3.0)

	random_offset = random_offset.lerp(target_random_offset, delta * 3.0)

	var move_direction : Vector2
	if distance_to_player < min_distance:
		move_direction = (-direction_to_player * 0.8 + random_offset * 0.2).normalized()
	elif distance_to_player > attack_range:
		move_direction = (direction_to_player * 0.7 + random_offset * 0.3).normalized()
	else:
		var strafe_direction = Vector2(-direction_to_player.y, direction_to_player.x)
		if random_offset.dot(strafe_direction) < 0:
			strafe_direction = -strafe_direction
		move_direction = (strafe_direction * 0.7 + random_offset * 0.3).normalized()

	var cardinal_direction = snap_to_8dir(move_direction)
	position += cardinal_direction * move_speed * delta

	var face_direction = snap_to_8dir(direction_to_player)
	if face_direction != Vector2.ZERO:
		rotation = face_direction.angle() + deg_to_rad(90)

	if distance_to_player <= attack_range and can_shoot:
		shoot_projectile()


func pick_random_direction() -> void:
	target_random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


func shoot_projectile() -> void:
	if not projectile_scene:
		push_warning("no projectile scene assigned to ranged enemy!")
		return
	
	attack_sound.play()
	play_attack_animation()
	projectiles_fired += 1

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position

	var direction = (player.global_position - global_position).normalized()
	if "velocity" in projectile:
		projectile.velocity = direction * projectile_speed
	elif "direction" in projectile:
		projectile.direction = direction
		projectile.speed = projectile_speed

	if projectiles_fired >= projectiles_per_cooldown:
		can_shoot = false
		projectiles_fired = 0
		start_attack_cooldown(projectile_cooldown_duration)
	else:
		can_shoot = false
		await get_tree().create_timer(time_between_shots).timeout
		can_shoot = true

func _on_attack_cooldown_timeout() -> void:
	super._on_attack_cooldown_timeout()
	can_shoot = true
