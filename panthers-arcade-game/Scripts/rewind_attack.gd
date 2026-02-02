extends Area2D

class_name RewindAttack

var hitbox : CollisionShape2D


# INFO: When the attack is spawned, disable its hitbox after a short delay, then delete it after a longer one
func _enter_tree() -> void:
	hitbox = $CollisionShape2D
	hitbox.disabled = false
	await get_tree().create_timer(0.1).timeout
	hitbox.disabled = true
	await get_tree().create_timer(0.4).timeout
	self.queue_free()


# INFO: When something enters the area, check if it's an enemy, and if so, damage it
func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		#  TODO: Add a function to damage the enemy, ex. area.damage(x)
		pass
	pass
