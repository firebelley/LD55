extends Node

@export var total_level_time: float
@export var max_enemies: int = 1
@export var spawn_area: ReferenceRect
@export var enemy_scenes: Array[PackedScene]
@export var enemy_spawn_times: Array[float]

@onready var level_timer: Timer = $LevelTimer
@onready var spawn_timer: Timer = $SpawnTimer


func _ready():
	level_timer.timeout.connect(on_level_timer_timeout)
	spawn_timer.timeout.connect(on_spawn_timer_timeout)
	
	level_timer.wait_time = total_level_time
	level_timer.start()
	spawn_timer.wait_time = 2
	spawn_timer.start()


func spawn():
	if (get_tree().get_nodes_in_group("enemy").size() >= max_enemies):
		return
	
	var rect = spawn_area.get_global_rect()

	var x = randf_range(rect.position.x, rect.end.x)
	var y = randf_range(rect.position.y, rect.end.y)
	var pos = Vector2(x, y)
	
	var entities_node = get_tree().get_first_node_in_group("entities")
	var enemy = enemy_scenes[0].instantiate() as Enemy
	enemy.global_position = pos
	entities_node.add_child(enemy)


func on_level_timer_timeout():
	print("level over")
	

func on_spawn_timer_timeout():
	if (level_timer.is_stopped()):
		return
	
	spawn()
	spawn_timer.start()
