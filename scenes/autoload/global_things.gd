extends Node


func shake_camera():
	get_tree().get_first_node_in_group("camera").shake()
