extends Control

@onready var letter1 = $Letter1
@onready var letter2 = $Letter2
@onready var letter3 = $Letter3
var alph := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var letters := []
var letter_selected := 0
var current1 := 0
var current2 := 0
var current3 := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	letter_selected = 0
	letters = [letter1, letter2, letter3]
	current1 = 0
	current2 = 0
	current3 = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if(is_visible()):
		var count = 0
		for i in letters:
			if(count == 0):
				i.text = alph[current1]
			if(count == 1):
				i.text = alph[current2]
			if(count == 2):
				i.text = alph[current3]
			if(letter_selected == count):
				letters[letter_selected].add_theme_color_override("font_color", Color(0.039, 1.0, 0.322, 1.0))
			else:
				i.add_theme_color_override("font_color", Color(255, 255, 255))
			count = count + 1
		if(Input.is_action_just_pressed("left")):
			if(letter_selected == 0):
				letter_selected = 2
			else:
				letter_selected = letter_selected - 1
		if(Input.is_action_just_pressed("right")):
			if(letter_selected == 2):
				letter_selected = 0
			else:
				letter_selected = letter_selected + 1
		if(Input.is_action_just_pressed("up")):
			if(letter_selected == 0):
				if(current1 == 0):
					current1 = 25
				else:
					current1 = current1 - 1
				letters[letter_selected].text = alph[current1]
			elif(letter_selected == 1):
				if(current2 == 0):
					current2 = 25
				else:
					current2 = current2 - 1
				letters[letter_selected].text = alph[current2]
			elif(letter_selected == 2):
				if(current3 == 0):
					current3 = 25
				else:
					current3 = current3 - 1
				letters[letter_selected].text = alph[current3]
		if(Input.is_action_just_pressed("down")):
			if(letter_selected == 0):
				if(current1 == 25):
					current1 = 0
				else:
					current1 = current1 + 1
				letters[letter_selected].text = alph[current1]
			elif(letter_selected == 1):
				if(current2 == 25):
					current2 = 0
				else:
					current2 = current2 + 1
				letters[letter_selected].text = alph[current2]
			elif(letter_selected == 2):
				if(current3 == 25):
					current3 = 0
				else:
					current3 = current3 + 1
				letters[letter_selected].text = alph[current3]
		if(Input.is_action_just_pressed("rewind")):
			var player_name = alph[current1] + alph[current2] + alph[current3]
			print("High score confirmed: ", player_name)
			get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
