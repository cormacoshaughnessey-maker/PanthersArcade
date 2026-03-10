extends Area2D

class_name Enemy

# base class for all enemies in the game

signal enemy_killed(score_value: int)

@export var max_health := 100.0
@export var move_speed := 150.0
@export var damage := 10.0
@export var score_value := 10  
@export var contact_damage_cooldown := 1.0

var paused := false
var invulnerable := false
var current_health : float
var player : CharacterBody2D  
var attack_cooldown := false
var can_deal_contact_damage := true
var is_dead := false

@onready var attack_timer : Timer = get_node_or_null("AttackCooldownTimer")
@onready var anim_sprite : AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")


#region Wave Spawning System

static var _current_wave := 0

const WAVE_INITIAL_ENEMY_COUNT := 2  # enemies in the first wave
const WAVE_MAX_ENEMY_COUNT := 7  # cap on enemies per wave
const WAVE_MINI_BOSS_EVERY := 5  # a mini boss spawns every X waves
const WAVE_SPAWN_X_MIN := 80.0
const WAVE_SPAWN_X_MAX := 1000.0
const WAVE_SPAWN_Y_OFFSET := -80.0  # pixels above the visible screen top


static func reset_wave_state() -> void:
	_current_wave = 0


#endregion


func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	self.add_to_group("enemies")
	self.add_to_group("pausable")



func _physics_process(delta: float) -> void:
	if not paused:
		move_and_attack(delta)
		clamp_to_screen()
		check_if_off_screen()

#keeping the enemies on screen
func clamp_to_screen() -> void:
	var canvas_transform = get_canvas_transform()
	var screen_size = get_viewport_rect().size
	var left = -canvas_transform.origin.x
	var right = -canvas_transform.origin.x + screen_size.x
	var top = -canvas_transform.origin.y
	var bottom = -canvas_transform.origin.y + screen_size.y

	var half_size := Vector2.ZERO
	var col_shape = get_node_or_null("CollisionShape2D")
	if col_shape and col_shape.shape is RectangleShape2D:
		half_size = col_shape.shape.size / 2.0
	elif col_shape and col_shape.shape is CircleShape2D:
		half_size = Vector2(col_shape.shape.radius, col_shape.shape.radius)

	global_position.x = clampf(global_position.x, left + half_size.x, right - half_size.x)
	if global_position.y >= top:
		global_position.y = clampf(global_position.y, top + half_size.y, bottom - half_size.y)


func check_if_off_screen() -> void:
	if not player:
		return
	if global_position.y > player.global_position.y + 800:
		queue_free() 

func move_and_attack(_delta: float) -> void:
	pass


func take_damage(amount: float) -> void:
	if is_dead:
		return
	if not invulnerable:
		current_health -= amount
		invulnerable = true
		await get_tree().create_timer(0.5).timeout
		invulnerable = false
	if current_health <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	enemy_killed.emit(score_value)
	queue_free()

var _pre_attack_animation : String = ""

func play_attack_animation(anim_name: String = "attack") -> void:
	if anim_sprite and anim_sprite.sprite_frames.has_animation(anim_name):
		var current := anim_sprite.animation as String
		if current == anim_name:
			anim_sprite.frame = 0
			anim_sprite.play(anim_name)
			if paused:
				anim_sprite.pause()
			return
		if not current.begins_with("attack"):
			_pre_attack_animation = current
		anim_sprite.play(anim_name)
		if paused:
			anim_sprite.pause()
		anim_sprite.animation_finished.connect(
			func():
				if is_instance_valid(self) and anim_sprite and _pre_attack_animation != "":
					anim_sprite.play(_pre_attack_animation),
			CONNECT_ONE_SHOT
		)


func start_attack_cooldown(cooldown_time: float) -> void:
	attack_cooldown = true
	if attack_timer:
		attack_timer.wait_time = cooldown_time
		attack_timer.start()
	else:
		await get_tree().create_timer(cooldown_time).timeout
		_on_attack_cooldown_timeout()

# called when attack timer finishes
func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		take_damage(area.damage if "damage" in area else 10)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_deal_contact_damage and body.has_method("lose_life"):
		body.lose_life()
		can_deal_contact_damage = false
		await get_tree().create_timer(contact_damage_cooldown).timeout
		can_deal_contact_damage = true


func pause(pausing:=true) -> void:
	paused = pausing
	if attack_timer:
		attack_timer.paused = pausing
	if anim_sprite:
		if pausing:
			anim_sprite.pause()
		else:
			anim_sprite.play(anim_sprite.animation)
