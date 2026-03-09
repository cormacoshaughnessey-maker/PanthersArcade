extends Control

@onready var names = [$Name1, $Name2, $Name3, $Name4, $Name5]
@onready var nums = [$Num1, $Num2, $Num3, $Num4, $Num5]
@onready var game_node
@onready var list
@onready var okay := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_node = get_tree().get_first_node_in_group("game")
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if(is_visible_in_tree()):
		update_high_score()

func update_high_score():
	okay = true
	list = game_node.high_score_list
	print(list)
	if(list.has("")):
		list.erase("")
	var maxim := 0
	var max_name := ""
	for i in range(5):
		maxim = 0
		max_name = ""
		if(list.size() <= 0):
			names[i].text = "NA"
			nums[i].text = "0"
		else:
			for j in range(list.values().size()):
				if(list.values()[j] > maxim):
					maxim = list.values()[j]
					max_name = list.keys()[j]
			names[i].text = max_name
			nums[i].text = str(maxim)
			list.erase(max_name)

func _physics_process(delta: float) -> void:
	if(okay):
		await get_tree().create_timer(5).timeout
		get_tree().reload_current_scene()
