class_name Skeleton
extends CharacterBody2D

const LAUNCH_SPEED = 500

@onready var launch_area: Area2D = $LaunchArea
@onready var collision_area: Area2D = $CollisionArea
@onready var collision_area_shape: CollisionShape2D = %CollisionAreaShape
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var skull_scene = preload("res://scenes/game_object/skull/skull.tscn")
var death_particles_scene = preload("res://scenes/effect/skeleton_death_particles.tscn")
var is_destroying = false

func _ready():
	launch_area.area_entered.connect(on_launch_area_entered)
	collision_area.area_entered.connect(on_collision_area_entered)


func _process(_delta):
	move_and_slide()
	
	var collision = get_last_slide_collision()
	if (collision != null):
		destroy(velocity)


func destroy(start_velocity: Vector2):
	var entities = get_tree().get_first_node_in_group("entities")
	
	var skull = skull_scene.instantiate() as Skull
	skull.global_position = global_position
	entities.add_child(skull)
	skull.start(start_velocity)
	
	var death_particles = death_particles_scene.instantiate() as GPUParticles2D
	death_particles.global_position = global_position
	entities.add_child(death_particles)
	
	queue_free()


func on_launch_area_entered(area: Area2D):
	var skeleton_launch_area: SkeletonLaunchArea = area.owner as SkeletonLaunchArea
	if (skeleton_launch_area == null):
		return
	
	velocity = skeleton_launch_area.direction * LAUNCH_SPEED
	collision_area_shape.set_deferred("disabled", false)
	animation_player.play("RESET")
	animation_player.queue("launch")


func on_collision_area_entered(area: Area2D):
	if (is_destroying):
		return

	var enemy = area.owner as Enemy
	if (enemy == null):
		return
	
	is_destroying = true
	destroy.call_deferred(Vector2.ZERO)
