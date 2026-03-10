extends Node2D

@onready var parallax_2d := $Parallax2D
@export var default_repeat_size := Vector2(0.0,3840.0)
@export var default_screen_offset := Vector2(0.0,1920.0)
@export var default_autoscroll_speed := 500.0

var scroll_speed : float:
	set(value):
		scroll_speed = value
		parallax_2d.autoscroll.y = value


 # INFO: Set everything to its default value
func _ready() -> void:
	default_autoscroll_speed = parallax_2d.autoscroll.y
	self.add_to_group("pausable")
	reset_parallax_values()


# INFO: Reset the scrolling speed to its default
func reset_scroll_speed() -> void:
	scroll_speed = default_autoscroll_speed


 # INFO: Pause the background if pause is true, unpause it if false
func pause(pausing:=true) -> void:
	if pausing:
		scroll_speed = 0
	else:
		reset_scroll_speed()


 # Set everything back to its default value
func reset_parallax_values() -> void:
	parallax_2d.repeat_size = default_repeat_size
	parallax_2d.autoscroll.y = default_autoscroll_speed
	parallax_2d.screen_offset = default_screen_offset
	pass
