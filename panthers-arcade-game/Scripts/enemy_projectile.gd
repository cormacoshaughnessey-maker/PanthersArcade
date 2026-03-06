extends Area2D

class_name EnemyProjectile

# enemy projectile that flies in a direction and damages the player

@export var damage := 10.0
@export var lifetime := 5.0  # auto-delete after this many seconds

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO  
var speed : float = 300.0 
var paused := false

func _ready() -> void:
	self.add_to_group("enemy_attack")
	self.add_to_group("pausable")

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	await get_tree().create_timer(lifetime).timeout
	queue_free()

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

func _on_area_entered(area: Area2D) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("lose_life") and body is Player:
		body.lose_life()
		queue_free() 

func pause(pause:=true) -> void:
	paused = pause
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		if pause:
			sprite.pause()
		else:
			sprite.play(sprite.animation)
