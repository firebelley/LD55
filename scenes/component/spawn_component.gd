class_name SpawnComponent
extends Node

signal finished


@export var spawn_area: ReferenceRect


var is_finished = false

func _process(_delta):
	if (is_finished):
		return

	var all_finished = get_children().all(func (child):
		return child.is_finished
	)
	var enemies_dead = get_tree().get_nodes_in_group("enemy").size() == 0
		
	if (all_finished && enemies_dead):
		finished.emit()
		is_finished = true
