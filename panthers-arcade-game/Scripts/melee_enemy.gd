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


func _ready() -> void:
	super._ready()
	pick_random_direction()
	random_offset = target_random_offset


func move_and_attack(delta: float) -> void:
	if not player:
		return

	var direction_to_player = (player.global_position - global_position).normalized()

	random_timer -= delta
	if random_timer <= 0:
		pick_random_direction()
		random_timer = randf_range(1.0, 2.0)

	random_offset = random_offset.lerp(target_random_offset, delta * 3.0)

	var final_direction = (direction_to_player * 0.7 + random_offset * 0.3).normalized()
	position += final_direction * move_speed * delta

	var target_rotation = final_direction.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, delta * 5.0)

	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range and can_attack:
		attack()

func pick_random_direction() -> void:
	target_random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


func attack() -> void:
	attacks_done += 1

	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range and player.has_method("take_damage"):
		player.take_damage(damage)

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
