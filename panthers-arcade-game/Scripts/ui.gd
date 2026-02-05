extends Control
		
var uilife_scene = preload("res://Scenes/ui_life.tscn")

@onready var lives = $Lives

func init_lives(amount):
	for u in lives.get_children():
		u.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
