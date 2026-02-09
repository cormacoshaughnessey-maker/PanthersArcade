extends Control

var rewind_bar_scene := preload("res://Scenes/rewind_ui_bar.tscn")

@onready var h_box_container := $HBoxContainer


 # INFO: Sets the number of lives displayed in the UI to be equal to a new amount
func fill_rewind_bar(amount:int):
	if h_box_container.get_children().size() == amount:
		return
	for u in h_box_container.get_children():
		u.queue_free()
	for i in amount:
		var ul = rewind_bar_scene.instantiate()
		h_box_container.add_child(ul)
