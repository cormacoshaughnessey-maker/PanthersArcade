extends Control

@onready var score_label: Label = $Score

var score: int = 0:
	set(value):
		score = value
		upd_score()

func upd_score():
	var text := str(score).pad_zeros(10)
	score_label.text = text
