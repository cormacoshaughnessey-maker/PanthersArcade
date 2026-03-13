extends Area2D

class_name EnemyProjectile

# enemy projectile that flies in a direction and damages the player

@export var damage := 10.0
@export var lifetime := 5.0  # auto-delete after this many seconds

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO
var speed : float = 300.0
var paused := false
var deflected := false
var deflected_sprite_texture = preload("res://Assets/Sprites/player_energyorb_spritesheet.png")

func _ready() -> void:
	self.add_to_group("enemy_attack")
	self.add_to_group("pausable")

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	#await get_tree().create_timer(lifetime).timeout
	#queue_free()

func _physics_process(delta: float) -> void:
	if not paused:
		if velocity != Vector2.ZERO:
			position += velocity * delta
		elif direction != Vector2.ZERO:
			position += direction * speed * delta
		if velocity != Vector2.ZERO:
			rotation = velocity.angle() + deg_to_rad(-90)
		elif direction != Vector2.ZERO:
			rotation = direction.angle() + deg_to_rad(-90)

		var screen_size = get_viewport_rect().size
		var canvas_transform = get_canvas_transform()
		var visible_rect = Rect2(-canvas_transform.origin, screen_size)
		visible_rect = visible_rect.grow(200)
		if not visible_rect.has_point(global_position):
			queue_free()


# when projectile hits something
func _on_area_entered(area: Area2D) -> void:
	if deflected and area is Enemy:
		area.die()
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("lose_life") and body is Player:
		if body.rewinding and not deflected:
			deflect()
		elif not body.is_invincible and not paused:
			body.lose_life()
			queue_free()  # destroy projectile after hitting


func deflect() -> void:
	if deflected:
		return
	deflected = true

	velocity = -velocity
	direction = -direction

	collision_layer = 8
	collision_mask = 4

	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		var new_frames = SpriteFrames.new()
		new_frames.set_animation_loop("default", true)
		new_frames.set_animation_speed("default", 10.0)
		for i in 6:
			var atlas_tex = AtlasTexture.new()
			atlas_tex.atlas = deflected_sprite_texture
			atlas_tex.region = Rect2(i * 128, 0, 128, 128)
			new_frames.add_frame("default", atlas_tex)
		sprite.sprite_frames = new_frames
		sprite.pause()

	remove_from_group("enemy_attack")
	add_to_group("player_attack")


func pause(pausing:=true) -> void:
	paused = pausing
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		if pausing:
			sprite.pause()
		else:
			sprite.play(sprite.animation)
