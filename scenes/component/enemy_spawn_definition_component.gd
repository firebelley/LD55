class_name EnemySpawnDefinitionComponent
extends Node


@onready var start_delay_timer: Timer = $StartDelayTimer
@onready var spawn_timer: Timer = $SpawnTimer

@export var spawn_lifetime: float
@export var spawn_begin_delay: float
@export var enemy_scene: PackedScene
@export var total_to_spawn: int

var is_finished = false
var total_spawned = 0

func _ready():
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	start_delay_timer.timeout.connect(on_start_delay_timeout)
	
	if (spawn_begin_delay > 0):
		start_delay_timer.wait_time = spawn_begin_delay
		start_delay_timer.start()
	else:
		begin_spawning()


func spawn():
	if (total_spawned >= total_to_spawn):
		return

	var parent = get_parent() as SpawnComponent
	var rect = parent.spawn_area.get_global_rect()

	var x = randf_range(rect.position.x, rect.end.x)
	var y = randf_range(rect.position.y, rect.end.y)
	var pos = Vector2(x, y)
	
	var entities_node = get_tree().get_first_node_in_group("entities")
	var enemy = enemy_scene.instantiate() as Node2D
	enemy.global_position = pos
	entities_node.add_child(enemy)
	total_spawned += 1
	is_finished = total_spawned >= total_to_spawn


func begin_spawning():
	spawn()
	if (spawn_lifetime > 0 && (total_to_spawn - 1) > 0):
		var delay_between_spawn = spawn_lifetime / (total_to_spawn - 1)
		spawn_timer.wait_time = delay_between_spawn
		spawn_timer.start()
	else:
		is_finished = true
		

func on_spawn_timer_timeout():
	spawn()


func on_start_delay_timeout():
	begin_spawning()
