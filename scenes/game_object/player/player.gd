extends CharacterBody2D

const ACCEL = 4000
const DECEL = 35
const MAX_SPEED = 175


const stored_skull_scene = preload("res://scenes/game_object/stored_skull/stored_skull.tscn")
const skeleton_scene = preload("res://scenes/game_object/skeleton/skeleton.tscn")


@onready var skull_pickup_area: Area2D = $SkullPickupArea
@onready var stored_skulls: Node2D = $StoredSkulls


func _ready():
	skull_pickup_area.area_entered.connect(_on_area_entered)
	

func _process(delta: float):
	var movement_vector = get_movement_vector()
	velocity += movement_vector * ACCEL * delta
	velocity = velocity.limit_length(MAX_SPEED)
	
	if (is_equal_approx(movement_vector.length_squared(), 0)):
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-DECEL * delta))
		
	move_and_slide()
	
	if (Input.is_action_just_pressed("place") && stored_skulls.get_child_count() > 0):
		summon_skeleton()


func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func summon_skeleton():
	var skeleton = skeleton_scene.instantiate()
	skeleton.global_position = global_position
	get_parent().add_child(skeleton)
	
	if (stored_skulls.get_child_count() > 0):
		stored_skulls.get_child(0).queue_free()


func _on_area_entered(area: Area2D):
	area.owner.queue_free()
	stored_skulls.add_child(stored_skull_scene.instantiate())
