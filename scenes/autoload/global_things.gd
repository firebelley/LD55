extends Node


func shake_camera():
	var camera = get_tree().get_first_node_in_group("camera")
	if (camera != null):
		camera.shake()
