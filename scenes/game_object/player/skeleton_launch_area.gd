class_name SkeletonLaunchArea
extends Node2D

var direction: Vector2
var frames = 0

func _ready():
	rotation = direction.angle()
	get_tree().physics_frame.connect(on_physics_frame)
	
	
func on_physics_frame():
	frames += 1
	if (frames >= 2):
		queue_free()
