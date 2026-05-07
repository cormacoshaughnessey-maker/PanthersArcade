extends Control

var button_grabbed := 0

func _ready() -> void:
	$VBoxContainer/PlayButton.grab_focus()
	button_grabbed = 0


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/instruction_screen.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up"):
		button_grabbed+=1
		if button_grabbed>1:
			button_grabbed = 0
		if button_grabbed == 1:
			$VBoxContainer/QuitButton.grab_focus()
		else:
			$VBoxContainer/PlayButton.grab_focus()
	if Input.is_action_just_pressed("rewind"):
		if button_grabbed == 1:
			$VBoxContainer/QuitButton.pressed.emit()
		else:
			$VBoxContainer/PlayButton.pressed.emit()
