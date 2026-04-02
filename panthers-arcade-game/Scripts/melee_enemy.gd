extends Enemy

class_name MeleeEnemy

@export var attack_range := 50.0
@export var attacks_per_cooldown := 2
@export var attack_cooldown_duration := 3.0
@export var time_between_attacks := 0.5
@export var movement_randomness := 100.0

var attacks_done := 0
var can_attack := true
var random_offset : Vector2
var target_random_offset : Vector2
var random_timer := 0.0
var _in_attack_range := false
var _last_snapped_direction := Vector2.ZERO


func _ready() -> void:
	death_sprite_texture = preload("res://Assets/Sprites/enemy_death_spritesheet.png")
	death_frame_size = 128
	super._ready()
	pick_random_direction()
	random_offset = target_random_offset


func move_and_attack(delta: float) -> void:
	if not player:
		return

	var direction_to_player = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)

	random_timer -= delta
	if random_timer <= 0:
		pick_random_direction()
		random_timer = randf_range(1.0, 2.0)

	random_offset = random_offset.lerp(target_random_offset, delta * 3.0)

	if distance_to_player <= attack_range:
		_in_attack_range = true
	elif distance_to_player > attack_range + 30.0:
		_in_attack_range = false

	if not _in_attack_range:
		var raw_direction = (direction_to_player * 0.7 + random_offset * 0.3).normalized()
		var new_snap = snap_to_8dir(raw_direction)
		if _last_snapped_direction == Vector2.ZERO or abs(raw_direction.angle() - _last_snapped_direction.angle()) > deg_to_rad(30):
			_last_snapped_direction = new_snap
		position += _last_snapped_direction * move_speed * delta

		if _last_snapped_direction != Vector2.ZERO:
			var target_rot = _last_snapped_direction.angle() + deg_to_rad(90)
			rotation = lerp_angle(rotation, target_rot, delta * 12.0)
	else:
		var target_rot = direction_to_player.angle() + deg_to_rad(90)
		rotation = lerp_angle(rotation, target_rot, delta * 8.0)

	if _in_attack_range and can_attack:
		attack()

func pick_random_direction() -> void:
	target_random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


func attack() -> void:
	play_attack_animation()
	attack_sound.play()
	attacks_done += 1

	if attacks_done >= attacks_per_cooldown:
		can_attack = false
		attacks_done = 0
		start_attack_cooldown(attack_cooldown_duration)
	else:
		can_attack = false
		await get_tree().create_timer(time_between_attacks).timeout
		can_attack = true

func _on_attack_cooldown_timeout() -> void:
	super._on_attack_cooldown_timeout()
	can_attack = true
