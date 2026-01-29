extends Area2D

class_name RewindAttack

@onready var hitbox := $CollisionShape2D

func _enter_tree() -> void:
	await get_tree().create_timer(5).timeout
	self.queue_free()
