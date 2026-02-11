extends Control

var uilife_scene = preload("res://Scenes/ui_life.tscn")

@onready var lives = $Lives


 # INFO: Sets the number of lives displayed in the UI to be equal to a new amount
func init_lives(amount:int):
	if lives.get_children().size() == amount:
		return
	for u in lives.get_children():
		u.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
