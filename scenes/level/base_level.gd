class_name BaseLevel
extends Node

signal level_finished
signal level_failed


@export var hide_intro_banner = false

@onready var spawn_component: SpawnComponent = $SpawnComponent
@onready var player: Player = %Player

const message_banner_scene = preload("res://scenes/ui/message_banner.tscn")


func _ready():
	spawn_component.finished.connect(on_finished)
	player.killed.connect(on_player_killed)
	
	if (!hide_intro_banner):
		var message_banner = message_banner_scene.instantiate() as MessageBanner
		add_child(message_banner)
		message_banner.play_warning()
		message_banner.finished.connect(on_intro_message_banner_finished)
	else:
		start_spawning()


func start_spawning():
	await get_tree().create_timer(.5).timeout
	spawn_component.start()


func on_finished():
	var message_banner = message_banner_scene.instantiate() as MessageBanner
	add_child(message_banner)
	message_banner.play_success()
	message_banner.finished.connect(on_final_message_banner_finished)
	

func on_player_killed():
	level_failed.emit()


func on_final_message_banner_finished():
	level_finished.emit()


func on_intro_message_banner_finished():
	start_spawning()
