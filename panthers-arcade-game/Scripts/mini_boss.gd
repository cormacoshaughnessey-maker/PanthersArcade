extends Enemy

class_name MiniBoss

@export var screen_top_offset := 380.0
@export var horizontal_speed := 200.0
@export var attack_pattern_cooldown := 5.0
@export var projectile_speed := 350.0
@export var melee_range := 120.0
@export var base_warning_duration := 1.5
@export var base_dive_duration := 1.0
@export var min_dive_duration := 0.3
@export var dive_speedup_per_wave := 0.02

@export var spread_shot_count := 5
@export var spread_angle := 60.0
@export var aimed_shot_count := 3

@export var projectile_scene : PackedScene

var warning_texture = preload("res://Assets/Sprites/boss_melee_warning_spritesheet.png")
var move_direction := 1.0
var can_attack := true
var attack_pattern := 0
var screen_size : Vector2
var is_diving := false

func _ready() -> void:
	death_sprite_texture = preload("res://Assets/Sprites/enemy_death_spritesheet.png")
	death_frame_size = 128
	super._ready()
	max_health = 300.0
	current_health = max_health
	score_value = 100
	screen_size = get_viewport_rect().size
	can_attack = false
	start_attack_cooldown(1.0)

func get_visible_screen_top() -> float:
	var canvas_transform = get_canvas_transform()
	var screen_top_world = -canvas_transform.origin.y
	return screen_top_world + screen_top_offset

func get_half_size_x() -> float:
	var col_shape = get_node_or_null("CollisionShape2D")
	if col_shape and col_shape.shape is RectangleShape2D:
		return col_shape.shape.size.x / 2.0 + abs(col_shape.position.x)
	elif col_shape and col_shape.shape is CircleShape2D:
		return col_shape.shape.radius + abs(col_shape.position.x)
	return 50.0

func get_visible_screen_bounds() -> Vector2:
	var canvas_transform = get_canvas_transform()
	var pad = get_half_size_x()
	var left = -canvas_transform.origin.x + pad
	var right = -canvas_transform.origin.x + screen_size.x - pad
	return Vector2(left, right)


func clamp_to_screen() -> void:
	var bounds = get_visible_screen_bounds()
	global_position.x = clampf(global_position.x, bounds.x, bounds.y)


func move_and_attack(delta: float) -> void:
	if not player:
		return

	if is_diving:
		return

	var target_y = get_visible_screen_top()
	global_position.y = lerp(global_position.y, target_y, delta * 3.0)

	var bounds = get_visible_screen_bounds()

	if global_position.x >= bounds.y:
		move_direction = -1.0
	elif global_position.x <= bounds.x:
		move_direction = 1.0

	global_position.x += move_direction * horizontal_speed * delta

	var direction_to_player = (player.global_position - global_position).normalized()
	var target_rotation = direction_to_player.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, delta * 5.0)

	if can_attack:
		execute_attack_pattern()


func execute_attack_pattern() -> void:
	can_attack = false

	match attack_pattern:
		0:
			await spread_shot_attack()
		1:
			await aimed_burst_attack()
		2:
			play_attack_animation("attack_melee")
			attack_sound_2.play()
			await melee_dive_attack()

	attack_pattern = (attack_pattern + 1) % 3

	start_attack_cooldown(attack_pattern_cooldown)


func spread_shot_attack() -> void:
	if not projectile_scene:
		push_warning("no projectile scene assigned to mini boss!")
		return

	var direction_to_player = (player.global_position - global_position).normalized()
	var base_angle = direction_to_player.angle()

	for i in range(spread_shot_count):
		while paused:
			await get_tree().process_frame
		play_attack_animation("attack_ranged")
		attack_sound.play()
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position

		var angle_offset = deg_to_rad(spread_angle) * (i - spread_shot_count / 2.0) / spread_shot_count
		var shot_angle = base_angle + angle_offset
		var shot_direction = Vector2.from_angle(shot_angle)

		if "velocity" in projectile:
			projectile.velocity = shot_direction * projectile_speed
		elif "direction" in projectile:
			projectile.direction = shot_direction
			projectile.speed = projectile_speed

		var wait = 0.0
		while wait < 0.1:
			if not paused:
				wait += get_physics_process_delta_time()
			await get_tree().process_frame


func aimed_burst_attack() -> void:
	if not projectile_scene:
		return

	for i in range(aimed_shot_count):
		while paused:
			await get_tree().process_frame
		play_attack_animation("attack_ranged")
		attack_sound.play()
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position

		var direction = (player.global_position - global_position).normalized()

		if "velocity" in projectile:
			projectile.velocity = direction * projectile_speed * 1.2
		elif "direction" in projectile:
			projectile.direction = direction
			projectile.speed = projectile_speed * 1.2

		var wait = 0.0
		while wait < 0.3:
			if not paused:
				wait += get_physics_process_delta_time()
			await get_tree().process_frame


func _spawn_melee_warning() -> AnimatedSprite2D:
	var warning = AnimatedSprite2D.new()
	var frames = SpriteFrames.new()
	frames.add_animation("flash")
	frames.set_animation_loop("flash", true)
	frames.set_animation_speed("flash", 12.0)
	for i in 2:
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = warning_texture
		atlas_tex.region = Rect2(i * 128, 0, 128, 128)
		frames.add_frame("flash", atlas_tex)
	warning.sprite_frames = frames
	warning.scale = Vector2(2, 2)
	warning.global_position = global_position + Vector2(0, -100)
	warning.play("flash")
	get_parent().add_child(warning)
	return warning


func melee_dive_attack() -> void:
	is_diving = true

	if not is_instance_valid(player):
		is_diving = false
		return

	var target_pos = player.global_position

	var warning = _spawn_melee_warning()
	var warn_elapsed = 0.0
	while warn_elapsed < base_warning_duration:
		if not paused:
			warning.play()
			warn_elapsed += get_physics_process_delta_time()
			if is_instance_valid(warning):
				warning.global_position = global_position + Vector2(0, -80)
		else:
			warning.pause()
		await get_tree().process_frame
	if is_instance_valid(warning):
		warning.queue_free()

	if not is_instance_valid(player):
		is_diving = false
		return

	var start_pos = global_position
	var has_dealt_damage = false

	var dive_duration = maxf(base_dive_duration - dive_speedup_per_wave * Enemy._current_wave, min_dive_duration)
	var elapsed = 0.0

	while elapsed < dive_duration:
		if not is_instance_valid(player):
			break
		if not paused:
			elapsed += get_physics_process_delta_time()
			var t = elapsed / dive_duration
			t = 1.0 - pow(1.0 - t, 3.0)
			global_position = start_pos.lerp(target_pos, t)
			# Deal contact damage when close enough to the player
			if not has_dealt_damage and global_position.distance_to(player.global_position) < melee_range:
				if player.has_method("lose_life"):
					player.lose_life()
					has_dealt_damage = true
		await get_tree().process_frame

	# Hold the arm-out frame while paused at player
	if anim_sprite and anim_sprite.sprite_frames.has_animation("attack_melee"):
		anim_sprite.play("attack_melee")
		anim_sprite.frame = 2
		anim_sprite.pause()

	var hold_elapsed = 0.0
	while hold_elapsed < 0.5:
		if not paused:
			hold_elapsed += get_physics_process_delta_time()
		await get_tree().process_frame

	# Return to default animation
	if anim_sprite:
		anim_sprite.play("default")
		if paused:
			anim_sprite.pause()

	var return_duration = 0.6
	elapsed = 0.0
	start_pos = global_position
	var return_y = get_visible_screen_top()
	target_pos = Vector2(global_position.x, return_y)

	while elapsed < return_duration:
		if not paused:
			elapsed += get_physics_process_delta_time()
			var t = elapsed / return_duration
			global_position = start_pos.lerp(target_pos, t)
		await get_tree().process_frame

	is_diving = false

func _on_attack_cooldown_timeout() -> void:
	super._on_attack_cooldown_timeout()
	can_attack = true
