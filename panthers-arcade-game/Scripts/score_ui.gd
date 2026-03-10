extends Control

@onready var score_label: Label = $Score

var score: int = 0:
	set(value):
		score = value
		upd_score()

func upd_score():
	var text := str(score).pad_zeros(10)
	score_label.text = text

var max_wait_time := 6.0
#var wait_time := 1.0
var max_bars := 20

var cooldown_bar_scene := preload("res://Scenes/cooldown_ui_bar.tscn")

@onready var multiplier_cooldown_bar := $MultiplierCooldownBar
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
	var m = snappedf(score_multiplier, 0.2)
	if m >= 2.0:
		multiplier_cooldown_bar.modulate = Color("ff004e")
	elif m >= 1.8:
		multiplier_cooldown_bar.modulate = Color("b10585")
	elif m >= 1.6:
		multiplier_cooldown_bar.modulate = Color("600088")
	elif m >= 1.4:
		multiplier_cooldown_bar.modulate = Color("ac29ce")
	elif m >= 1.2:
		multiplier_cooldown_bar.modulate = Color("ff5cff")
	else:
		multiplier_cooldown_bar.modulate = Color("ffffff")
	
