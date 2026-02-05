extends Node2D

@onready var hud = $UI/UI


 # INFO: Variable for the lives the player has remaining, with an accompanying set function which updates the UI
var lives = 3:
	set(value):
		lives = value
		hud.init_lives(lives)


 # INFO: Function run only once when the game starts running
func _ready():
	lives = 3
