extends Sprite2D

var game_node : Node2D
var player : Player


# INFO: Get the player when the projection is created
func _enter_tree() -> void:
	#self.add_to_group("player_projections")
	player = get_tree().get_first_node_in_group("player")
	pass


 # INFO: Delete this if the player stops rewinding
func _physics_process(_delta: float) -> void:
	if not player.rewinding:
		queue_free()
