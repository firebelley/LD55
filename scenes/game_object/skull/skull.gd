class_name Skull
extends CharacterBody2D

const FRICTION = 1.5


func _ready():
	pass
	
	
func _process(delta):
	move_and_slide()
	velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-FRICTION * delta))
	
	var last_collision = get_last_slide_collision()
	if (last_collision != null):
		var normal = last_collision.get_normal()
		velocity = velocity.bounce(normal)


func start(initial_velocity: Vector2):
	velocity = initial_velocity
