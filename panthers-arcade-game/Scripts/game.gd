extends Node2D

@onready var health_ui = $UI/HealthUI
@onready var rewind_ui = $UI/RewindUI
@onready var player = $Player

 # INFO: Variable for the lives the player has remaining, with an accompanying set function which updates the UI
var lives = 3:
	set(value):
		lives = value
		health_ui.init_lives(lives)

 # INFO: Function run only once when the game starts running
func _ready():
	lives = 3

func _physics_process(delta: float) -> void:
	rewind_ui.fill_rewind_bar(player.rewind_data_length()/2)
	pass
