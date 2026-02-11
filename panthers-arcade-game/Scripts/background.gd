extends Node2D

@onready var parallax_2d := $Parallax2D
var default_autoscroll_speed : float

var scroll_speed : float:
	set(value):
		scroll_speed = value
		parallax_2d.autoscroll.y = value


func _ready() -> void:
	default_autoscroll_speed = parallax_2d.autoscroll.y
	self.add_to_group("pausable")


func reset_scroll_speed() -> void:
	scroll_speed = default_autoscroll_speed


func pause(pause:=true) -> void:
	if pause:
		scroll_speed = 0
	else:
		reset_scroll_speed()
