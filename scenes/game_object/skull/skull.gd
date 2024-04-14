class_name Skull
extends CharacterBody2D

const FRICTION = 1.5

const skeleton_scene = preload("res://scenes/game_object/skeleton/skeleton.tscn")

@onready var pickup_area: Area2D = $PickupArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	pickup_area.area_entered.connect(on_skull_pickup_area_entered)
	
	
func _process(delta):
	move_and_slide()
	velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-FRICTION * delta))
	
	var last_collision = get_last_slide_collision()
	if (last_collision != null):
		var normal = last_collision.get_normal()
		velocity = velocity.bounce(normal)


func start(initial_velocity: Vector2):
	velocity = initial_velocity


func summon_skeleton():
	var skeleton = skeleton_scene.instantiate()
	skeleton.global_position = global_position + (Vector2.DOWN * 4)
	get_parent().add_child(skeleton)


func on_skull_pickup_area_entered(_area: Area2D):
	velocity = Vector2.ZERO
	animation_player.play("summon")

