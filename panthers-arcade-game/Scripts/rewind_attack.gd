extends Area2D

class_name RewindAttack

@export var damage := 100.0

var hitbox : CollisionShape2D


func _ready() -> void:
	add_to_group("player_attack")


# INFO: When the attack is spawned, disable its hitbox after a short delay, then delete it after a longer one
func _enter_tree() -> void:
	hitbox = $CollisionShape2D
	hitbox.disabled = false
	#await get_tree().create_timer(0.3).timeout
	#hitbox.disabled = true
	#await get_tree().create_timer(0.2).timeout


# INFO: When something enters the area, check if it's an enemy, and if so, damage it
func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		area.take_damage(damage)


func hide_sprite(hiding := true) -> void:
	$AnimatedSprite2D.visible = not hiding


func _on_animated_sprite_2d_animation_finished() -> void:
	self.queue_free()
