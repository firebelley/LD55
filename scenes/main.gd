extends Node

@export var level_sequence: Array[PackedScene]

var level_index = 0

func _ready():
	advance_level()


func advance_level():
	if (level_sequence.size() <= level_index):
		return
	
	var level_scene = level_sequence[level_index].instantiate() as BaseLevel
	level_index += 1
	
	for child in get_children():
		if child is BaseLevel:
			child.queue_free()
		
	level_scene.level_finished.connect(on_level_finished)

	add_child(level_scene)


func on_level_finished():
	advance_level()
