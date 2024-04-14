extends Node


func _ready():
	if (!OS.has_feature("web") && !OS.is_debug_build()):
		get_window().mode = Window.MODE_FULLSCREEN
		get_window().borderless = true


func _unhandled_input(event):
	if (OS.has_feature("web")):
		return

	if (event.is_action_pressed("fullscreen")):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
			get_window().borderless = false
		else:
			get_window().mode = Window.MODE_FULLSCREEN
			get_window().borderless = true
	
	if (event.is_action_pressed("mute")):
		var bus_idx = AudioServer.get_bus_index("Master")
		var is_muted = AudioServer.is_bus_mute(bus_idx)
		AudioServer.set_bus_mute(bus_idx, !is_muted)

