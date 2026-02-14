extends Enemy

class_name MiniBoss

# mini boss enemy with attack patterns
# moves left and right at the top of the screen
# has 2 projectile attacks and 1 melee attack

@export var screen_top_offset := 100.0  # how far from top of visible screen to stay
@export var horizontal_speed := 200.0
@export var attack_pattern_cooldown := 5.0  # time between attack patterns
@export var projectile_speed := 350.0
@export var melee_range := 120.0

# projectile attack settings
@export var spread_shot_count := 5  # how many projectiles in spread attack
@export var spread_angle := 60.0  # degrees of spread
@export var aimed_shot_count := 3  # how many shots in the aimed burst

@export var projectile_scene : PackedScene 

var moving_right := true
var can_attack := true
var attack_pattern := 0 
var screen_size : Vector2  
var is_diving := false  


func _ready() -> void:
	super._ready()
	max_health = 300.0
	current_health = max_health
	score_value = 100
	screen_size = get_viewport_rect().size

func get_visible_screen_top() -> float:
	var canvas_transform = get_canvas_transform()
	var screen_top_world = -canvas_transform.origin.y
	return screen_top_world + screen_top_offset

func get_visible_screen_bounds() -> Vector2:
	var canvas_transform = get_canvas_transform()
	var left = -canvas_transform.origin.x + 50  # 50 pixel margin
	var right = -canvas_transform.origin.x + screen_size.x - 50
	return Vector2(left, right)


# main loop: move horizontally and do attack patterns
func move_and_attack(delta: float) -> void:
	if not player:
		return

	if is_diving:
		return

	var target_y = get_visible_screen_top()
	global_position.y = lerp(global_position.y, target_y, delta * 3.0)

	# get the visible screen bounds so we bounce off the right edges
	var bounds = get_visible_screen_bounds()

	# move left and right
	if moving_right:
		global_position.x += horizontal_speed * delta
		if global_position.x > bounds.y:
			moving_right = false
	else:
		global_position.x -= horizontal_speed * delta
		if global_position.x < bounds.x:
			moving_right = true

	# always face the player
	var direction_to_player = (player.global_position - global_position).normalized()
	rotation = direction_to_player.angle() + deg_to_rad(90)

	# do attack patterns
	if can_attack:
		execute_attack_pattern()


# cycle through different attack patterns
func execute_attack_pattern() -> void:
	can_attack = false

	match attack_pattern:
		0:
			# spread shot: fires projectiles in a cone
			await spread_shot_attack()
		1:
			# aimed burst: shoots multiple projectiles directly at player
			await aimed_burst_attack()
		2:
			# melee dive: dashes toward player and does melee damage
			await melee_dive_attack()

	# cycle to next pattern
	attack_pattern = (attack_pattern + 1) % 3

	# cooldown before next pattern
	start_attack_cooldown(attack_pattern_cooldown)


# attack 1: spread shot in a cone shape
func spread_shot_attack() -> void:
	if not projectile_scene:
		push_warning("no projectile scene assigned to mini boss!") # temp debug message
		return

	var direction_to_player = (player.global_position - global_position).normalized()
	var base_angle = direction_to_player.angle()

	# fire multiple projectiles in a spread
	for i in range(spread_shot_count):
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position

		# calculate angle for this projectile
		var angle_offset = deg_to_rad(spread_angle) * (i - spread_shot_count / 2.0) / spread_shot_count
		var shot_angle = base_angle + angle_offset
		var shot_direction = Vector2.from_angle(shot_angle)

		if "velocity" in projectile:
			projectile.velocity = shot_direction * projectile_speed
		elif "direction" in projectile:
			projectile.direction = shot_direction
			projectile.speed = projectile_speed

		await get_tree().create_timer(0.1).timeout


# attack 2: rapid fire aimed shots at player
func aimed_burst_attack() -> void:
	if not projectile_scene:
		return

	for i in range(aimed_shot_count):
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position

		var direction = (player.global_position - global_position).normalized()

		if "velocity" in projectile:
			projectile.velocity = direction * projectile_speed * 1.2  # slightly faster
		elif "direction" in projectile:
			projectile.direction = direction
			projectile.speed = projectile_speed * 1.2

		# delay between shots
		await get_tree().create_timer(0.3).timeout


# attack 3: dive toward player for melee damage
func melee_dive_attack() -> void:
	# TODO: play dive attack animation/sound
	is_diving = true

	var start_pos = global_position
	var target_pos = player.global_position

	# quick dive toward player
	var dive_duration = 0.4
	var elapsed = 0.0

	while elapsed < dive_duration:
		elapsed += get_physics_process_delta_time()
		var t = elapsed / dive_duration
		t = 1.0 - pow(1.0 - t, 3.0)
		global_position = start_pos.lerp(target_pos, t)
		await get_tree().process_frame

	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= melee_range:
		if player.has_method("take_damage"):
			player.take_damage(damage * 2)  # melee hits harder
		print("mini boss hit player with melee!")

	# pause briefly
	await get_tree().create_timer(0.5).timeout

	# return to top of visible screen
	var return_duration = 0.6
	elapsed = 0.0
	start_pos = global_position
	var return_y = get_visible_screen_top()
	target_pos = Vector2(global_position.x, return_y)

	while elapsed < return_duration:
		elapsed += get_physics_process_delta_time()
		var t = elapsed / return_duration
		global_position = start_pos.lerp(target_pos, t)
		await get_tree().process_frame

	is_diving = false

func _on_attack_cooldown_timeout() -> void:
	super._on_attack_cooldown_timeout()
	can_attack = true
