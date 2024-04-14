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
		is_finished = true
		get_tree().create_timer(1).timeout.connect(on_timer_timeout)


func start():
	for child in get_children():
		child.start()


func on_timer_timeout():
	finished.emit()
