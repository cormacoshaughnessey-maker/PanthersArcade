extends Sprite2D

var game_node : Node2D
var player : Player


func _enter_tree() -> void:
	#self.add_to_group("player_projections")
	player = get_tree().get_first_node_in_group("player")
	pass


func _physics_process(delta: float) -> void:
	if not player.rewinding:
		queue_free()
