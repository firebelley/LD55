class_name BaseLevel
extends Node

signal level_finished


@onready var spawn_component: SpawnComponent = $SpawnComponent


func _ready():
	spawn_component.finished.connect(on_finished)
	

func on_finished():
	level_finished.emit()
	

