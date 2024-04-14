class_name BaseLevel
extends Node

signal level_finished
signal level_failed


@export var hide_intro_banner = false

@onready var spawn_component: SpawnComponent = $SpawnComponent
@onready var player: Player = %Player
@onready var level_label: Label = %LevelLabel
@onready var total_level_timer: Timer = $TotalLevelTimer
@onready var timer_label: Label = %TimerLabel

const message_banner_scene = preload("res://scenes/ui/message_banner.tscn")


func _ready():
	spawn_component.finished.connect(on_finished)
	player.killed.connect(on_player_killed)
	
	var total_time = spawn_component.get_total_level_time()
	if (total_time > 0):
		total_level_timer.wait_time = total_time
		timer_label.text = str(ceil(total_level_timer.wait_time))
	
	set_process(false)
	
	if (!hide_intro_banner):
		var message_banner = message_banner_scene.instantiate() as MessageBanner
		add_child(message_banner)
		message_banner.play_warning()
		message_banner.finished.connect(on_intro_message_banner_finished)
	else:
		start_spawning()


func _process(_delta):
	timer_label.text = str(ceil(total_level_timer.time_left))


func start_spawning():
	await get_tree().create_timer(.5).timeout
	set_process(true)
	total_level_timer.start()
	spawn_component.start()


func update_level_label(level_index: int):
	level_label.text = "Level " + str(level_index + 1) + "/7"


func on_finished():
	var message_banner = message_banner_scene.instantiate() as MessageBanner
	add_child(message_banner)
	message_banner.play_success()
	message_banner.finished.connect(on_final_message_banner_finished)
	

func on_player_killed():
	await get_tree().create_timer(.5).timeout
	var message_banner = message_banner_scene.instantiate() as MessageBanner
	add_child(message_banner)
	message_banner.play_death()
	message_banner.finished.connect(on_death_message_banner_finished)


func on_final_message_banner_finished():
	level_finished.emit()


func on_intro_message_banner_finished():
	start_spawning()


func on_death_message_banner_finished():
	if (get_tree().current_scene.scene_file_path.contains("level_")):
		await get_tree().physics_frame
		get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
	else:
		level_failed.emit()
