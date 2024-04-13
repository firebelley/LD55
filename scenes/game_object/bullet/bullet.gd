class_name Bullet
extends CharacterBody2D


const SPEED = 150


func _process(_delta):
	move_and_slide()
	
	if (get_last_slide_collision() != null):
		queue_free()


func start(direction: Vector2):
	velocity = direction * SPEED
