extends Node


signal enemy_killed


func shake_camera():
	var camera = get_tree().get_first_node_in_group("camera")
	if (camera != null):
		camera.shake()


func emit_enemy_killed():
	enemy_killed.emit()
