extends Control

@onready var letter1 = $Letter1
@onready var letter2 = $Letter2
@onready var letter3 = $Letter3
@onready var high_score_display
@onready var score_scene = get_tree().get("Score")
@onready var game_node := get_tree().get_first_node_in_group("game")
var alph := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var letters := []
var letter_selected := 0
#var current1 := 0
#var current2 := 0
#var current3 := 0
var current_index := [0,0,0]
var player_name := ""
var not_done := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	high_score_display = get_node("/root/Game/UI/HighScoreDisplay")
	letter_selected = 0
	letters = [letter1, letter2, letter3]
	#current1 = 0
	#current2 = 0
	#current3 = 0
	current_index = [0,0,0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if(is_visible()):
		var count = 0
		for i in letters:
			#if(count == 0):
				#i.text = alph[current_index[0]]
			#if(count == 1):
				#i.text = alph[current_index[1]]
			#if(count == 2):
				#i.text = alph[current_index[2]]
			i.text = alph[current_index[count]]
			if(letter_selected == count):
				letters[letter_selected].add_theme_color_override("font_color", Color(0.039, 1.0, 0.322, 1.0))
			else:
				i.add_theme_color_override("font_color", Color(255, 255, 255))
			count += 1
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
			#if(letter_selected == 0):
				#if(current_index[0] == 0):
					#current_index[0] = 25
				#else:
					#current_index[0] = current_index[0] - 1
				#letters[letter_selected].text = alph[current_index[0]]
			#elif(letter_selected == 1):
				#if(current_index[1] == 0):
					#current_index[1] = 25
				#else:
					#current_index[1] = current_index[1] - 1
				#letters[letter_selected].text = alph[current_index[1]]
			#elif(letter_selected == 2):
				#if(current_index[2] == 0):
					#current_index[2] = 25
				#else:
					#current_index[2] = current_index[2] - 1
				#letters[letter_selected].text = alph[current_index[2]]
			if(current_index[letter_selected] == 0):
				current_index[letter_selected] = 25
			else:
				current_index[letter_selected] = current_index[letter_selected] - 1
			letters[letter_selected].text = alph[current_index[letter_selected]]
		if(Input.is_action_just_pressed("down")):
			#if(letter_selected == 0):
				#if(current_index[0] == 25):
					#current_index[0] = 0
				#else:
					#current_index[0] = current_index[0] + 1
				#letters[letter_selected].text = alph[current_index[0]]
			#elif(letter_selected == 1):
				#if(current_index[1] == 25):
					#current_index[1] = 0
				#else:
					#current_index[1] = current_index[1] + 1
				#letters[letter_selected].text = alph[current_index[1]]
			#elif(letter_selected == 2):
				#if(current_index[2] == 25):
					#current_index[2] = 0
				#else:
					#current_index[2] = current_index[2] + 1
				#letters[letter_selected].text = alph[current_index[2]]
			if(current_index[letter_selected] == 25):
				current_index[letter_selected] = 0
			else:
				current_index[letter_selected] = current_index[letter_selected] + 1
			letters[letter_selected].text = alph[current_index[letter_selected]]
		if(not_done && Input.is_action_just_pressed("rewind")):
			player_name = alph[current_index[0]] + alph[current_index[1]] + alph[current_index[2]]
			print("High score confirmed: ", player_name)
			game_node.save_score()
			not_done = false
			high_score_display.visible = true
