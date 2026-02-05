extends Node2D

@onready var hud = $UI

var lives = 3:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	lives = 3
