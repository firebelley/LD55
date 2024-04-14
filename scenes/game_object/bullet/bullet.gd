class_name Bullet
extends CharacterBody2D


const SPEED = 150


@onready var area: Area2D = $Area2D

const blaster_particles_scene = preload("res://scenes/effect/blaster_particles.tscn")


func _ready():
	area.area_entered.connect(on_area_entered)
	$RandomAudioStreamPlayer.play_random()


func _process(_delta):
	move_and_slide()
	
	var last_collision = get_last_slide_collision()
	if (last_collision != null):
		destroy(last_collision.get_normal())


func start(direction: Vector2):
	velocity = direction * SPEED


func destroy(direction: Vector2):
	var entities = get_tree().get_first_node_in_group("entities")
	var particles = blaster_particles_scene.instantiate() as Node2D
	entities.add_child(particles)
	particles.global_position = global_position
	particles.rotation = direction.angle()
	queue_free()


func on_area_entered(other_area: Area2D):
	var direction = other_area.global_position.direction_to(global_position)
	destroy(direction)
