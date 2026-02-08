extends Area2D

class_name RewindAttack

@export var damage := 10.0

@onready var hitbox := $CollisionShape2D

func _ready() -> void:
	add_to_group("player_attack")

func _enter_tree() -> void:
	await get_tree().create_timer(5).timeout
	self.queue_free()
