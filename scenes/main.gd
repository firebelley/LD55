extends Node

@export var level_sequence: Array[PackedScene]

var level_index = 0

func _ready():
	advance_level()


func advance_level():
	if (level_sequence.size() <= level_index):
		return
	
	if (level_index > 0):
		ScreenTransition.transition()
		await ScreenTransition.transitioned_halfway
		
	var level_scene = level_sequence[level_index].instantiate() as BaseLevel
	level_index += 1

	for child in get_children():
		if child is BaseLevel:
			remove_child(child)
			child.queue_free()
		
	level_scene.level_finished.connect(on_level_finished)
	level_scene.level_failed.connect(on_level_failed)

	add_child(level_scene)


func restart_level():
	level_index -= 1
	advance_level()


func on_level_finished():
	advance_level()


func on_level_failed():
	restart_level.call_deferred()
