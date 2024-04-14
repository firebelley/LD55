extends CanvasLayer


func _process(_delta):
	if (Input.is_action_just_pressed("restart")):
		ScreenTransition.transition_to_scene("res://scenes/main.tscn")
	if (Input.is_action_just_pressed("quit")):
		get_tree().quit()
