class_name Skeleton
extends CharacterBody2D

const LAUNCH_SPEED = 500

@onready var launch_area: Area2D = $LaunchArea
@onready var collision_area: Area2D = $CollisionArea
@onready var collision_area_shape: CollisionShape2D = %CollisionAreaShape
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow_sprite: Sprite2D = %ArrowSprite
@onready var arrow_root: Node2D = $ArrowRoot


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
		
	update_arrow()


func destroy(start_velocity: Vector2):
	var entities = get_tree().get_first_node_in_group("entities")
	
	var skull_scene = load("res://scenes/game_object/skull/skull.tscn")
	var skull = skull_scene.instantiate() as Skull
	skull.global_position = global_position
	entities.add_child(skull)
	skull.start(start_velocity)
	
	var death_particles = death_particles_scene.instantiate() as GPUParticles2D
	death_particles.global_position = global_position
	entities.add_child(death_particles)
	
	queue_free()


func update_arrow():
	var player = get_tree().get_first_node_in_group("player") as Player
	if (player == null):
		arrow_sprite.visible = false
		return
	
	if (player.center_marker.global_position.distance_to(arrow_root.global_position) < 32):
		arrow_sprite.visible = true
	else:
		arrow_sprite.visible = false
	
	var direction = (get_global_mouse_position() - player.center_marker.global_position).normalized()
	arrow_root.rotation = direction.angle()


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

	var enemy = area.owner as Node2D
	if (enemy == null):
		return
	
	is_destroying = true
	destroy.call_deferred(Vector2.ZERO)
