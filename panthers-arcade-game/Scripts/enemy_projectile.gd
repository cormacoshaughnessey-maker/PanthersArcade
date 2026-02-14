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
		# move the projectile
		if velocity != Vector2.ZERO:
			position += velocity * delta
		elif direction != Vector2.ZERO:
			position += direction * speed * delta

		# rotate to face direction of travel
		if velocity != Vector2.ZERO:
			rotation = velocity.angle() + deg_to_rad(90)
		elif direction != Vector2.ZERO:
			rotation = direction.angle() + deg_to_rad(90)

		# clean up projectiles that went way off screen
		var screen_size = get_viewport_rect().size
		var canvas_transform = get_canvas_transform()
		var visible_rect = Rect2(-canvas_transform.origin, screen_size)
		# add some buffer so projectiles just off screen aren't deleted immediately
		visible_rect = visible_rect.grow(200)
		if not visible_rect.has_point(global_position):
			queue_free()


# when projectile hits something
func _on_area_entered(area: Area2D) -> void:
	# if enemy hits a player attack, destroy the projectile
	#if area.is_in_group("player_attack"):
		#queue_free()
	pass


# when projectile hits the player
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("lose_life") and body is Player:
		body.lose_life()
		queue_free()  # destroy projectile after hitting


func pause(pause:=true) -> void:
	paused = pause
