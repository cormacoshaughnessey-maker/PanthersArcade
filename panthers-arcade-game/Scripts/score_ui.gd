extends Control

var max_wait_time := 6.0
#var wait_time := 1.0
var max_bars := 20

var cooldown_bar_scene := preload("res://Scenes/cooldown_ui_bar.tscn")

@onready var multiplier_cooldown_bar := $MultiplierCooldownBar
@onready var score = $Score:
	set(value):
		var num_digits := str(value).length()
		var empty := ""
		if(num_digits < 10):
			for i in range(10-num_digits):
				empty = empty + "0"
		else:
			empty = str(value)
		empty = empty + str(value)
		score.text = empty
@onready var score_multiplier_label = $ScoreMultiplier:
	set(value):
		var new_text := str(value)+"x"
		if value == 1.0:
			score_multiplier_label.text = ""
		else:
			score_multiplier_label.text = new_text
		


func fill_cooldown_bar(wait_time:float, score_multiplier:=1.0):
	var amount = (wait_time/max_wait_time) * max_bars
	if multiplier_cooldown_bar.get_children().size() == amount:
		return
	for u in multiplier_cooldown_bar.get_children():
		u.queue_free()
	for i in amount:
		var ul = cooldown_bar_scene.instantiate()
		multiplier_cooldown_bar.add_child(ul)
	score_multiplier_label = score_multiplier
	color_multiplier_bar(score_multiplier)


func color_multiplier_bar(score_multiplier) -> void:
	match score_multiplier:
		1.2:
			multiplier_cooldown_bar.modulate = Color("ff5cff")
		1.4:
			multiplier_cooldown_bar.modulate = Color("ac29ce")
		1.6:
			multiplier_cooldown_bar.modulate = Color("600088")
		1.8:
			multiplier_cooldown_bar.modulate = Color("b10585")
		2.0:
			multiplier_cooldown_bar.modulate = Color("ff004e")
		_:
			multiplier_cooldown_bar.modulate = Color("ffffff")
	
