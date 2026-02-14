extends Enemy

class_name MeleeEnemy

# melee enemy that walks toward the player and hits them
# does 1-2 attacks then goes on cooldown

@export var attack_range := 50.0  # how close it needs to be to attack
@export var attacks_per_cooldown := 2  # how many attacks before cooldown
@export var attack_cooldown_duration := 3.0  # seconds between attack bursts
@export var time_between_attacks := 0.5  # seconds between each attack in a burst
@export var movement_randomness := 100.0  # how much random movement to add

var attacks_done := 0  # track how many attacks it's done in this burst
var can_attack := true
var random_offset : Vector2  # random movement direction
var random_timer := 0.0


func _ready() -> void:
	super._ready()  
	pick_random_direction()
	print("melee enemy ready! player found: ", player != null)


# main loop: move toward player and attack when close enough
func move_and_attack(delta: float) -> void:
	if not player:
		return

	# move toward the player with some random movement
	var direction_to_player = (player.global_position - global_position).normalized()

	random_timer -= delta
	if random_timer <= 0:
		pick_random_direction()
		random_timer = randf_range(1.0, 2.0)  # pick new direction every 1-2 seconds

	var final_direction = (direction_to_player * 0.7 + random_offset * 0.3).normalized()
	position += final_direction * move_speed * delta

	rotation = final_direction.angle() + deg_to_rad(90)  # add 90 if sprite faces up by default
	
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range and can_attack:
		attack()

func pick_random_direction() -> void:
	random_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


# do a melee attack
func attack() -> void:
	attacks_done += 1

	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range and player.has_method("take_damage"):
		player.take_damage(damage)
		print("melee enemy hit player!")  

	# check if done enough attacks to go on cooldown
	if attacks_done >= attacks_per_cooldown:
		can_attack = false
		attacks_done = 0
		start_attack_cooldown(attack_cooldown_duration)
	else:
		# short delay between attacks in the same burst
		can_attack = false
		await get_tree().create_timer(time_between_attacks).timeout
		can_attack = true

func _on_attack_cooldown_timeout() -> void:
	super._on_attack_cooldown_timeout()
	can_attack = true
