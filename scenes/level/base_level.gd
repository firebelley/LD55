class_name BaseLevel
extends Node

signal level_finished
signal level_failed


@onready var spawn_component: SpawnComponent = $SpawnComponent
@onready var player: Player = %Player


func _ready():
	spawn_component.finished.connect(on_finished)
	player.killed.connect(on_player_killed)
	

func on_finished():
	level_finished.emit()
	

func on_player_killed():
	level_failed.emit()
