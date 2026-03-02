extends Control

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
