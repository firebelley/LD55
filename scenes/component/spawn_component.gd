class_name SpawnComponent
extends Node

signal finished

@export var total_enemies_to_spawn: int
@export var total_level_time: float
@export var spawn_area: ReferenceRect
@export var enemy_scenes: Array[PackedScene]
@export var enemy_spawn_times: Array[float]

@onready var level_timer: Timer = $LevelTimer
@onready var spawn_timer: Timer = $SpawnTimer


var is_finished = false
var enemies_dead = false

func _ready():
	level_timer.timeout.connect(on_level_timer_timeout)
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	
	if (total_level_time > 0):
		level_timer.wait_time = total_level_time
		level_timer.start()
	else:
		is_finished = true
	
	var spawn_timer_time = total_level_time / total_enemies_to_spawn
	if (spawn_timer_time > 0):
		spawn_timer.wait_time = total_level_time / total_enemies_to_spawn 
		spawn_timer.start()


func _process(_delta):
	if (is_finished && !enemies_dead):
		enemies_dead = get_tree().get_nodes_in_group("enemy").size() == 0
		if (enemies_dead):
			finished.emit()


func spawn():
	var rect = spawn_area.get_global_rect()

	var x = randf_range(rect.position.x, rect.end.x)
	var y = randf_range(rect.position.y, rect.end.y)
	var pos = Vector2(x, y)
	
	var entities_node = get_tree().get_first_node_in_group("entities")
	var enemy = enemy_scenes[0].instantiate() as Node2D
	enemy.global_position = pos
	entities_node.add_child(enemy)


func on_level_timer_timeout():
	is_finished = true
	

func on_spawn_timer_timeout():
	if (!level_timer.is_stopped()):
		spawn_timer.start()
	
	spawn()
	
