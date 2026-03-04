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
		check_if_off_screen()
		if anim_sprite and anim_sprite.sprite_frames.has_animation("move"):
			anim_sprite.play("move")
	else:
		if anim_sprite and anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")


func check_if_off_screen() -> void:
	if not player:
		return
	if global_position.y > player.global_position.y + 800:
		queue_free() 

func move_and_attack(_delta: float) -> void:
	pass


func take_damage(amount: float) -> void:
	if not invulnerable:
		current_health -= amount
		invulnerable = true
		await get_tree().create_timer(0.5).timeout
		invulnerable = false
	if current_health <= 0:
		die()



func die() -> void:
	# TODO: play death animation/particle effect
	enemy_killed.emit(score_value)
	queue_free()  

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
	if body.is_in_group("player") and body is Player:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if body.has_method("lose_life"):
			body.lose_life()
		#can_deal_contact_damage = false
		#await get_tree().create_timer(contact_damage_cooldown).timeout
		#can_deal_contact_damage = true


func pause(pause:=true) -> void:
	paused = pause
	attack_timer.paused = pause
