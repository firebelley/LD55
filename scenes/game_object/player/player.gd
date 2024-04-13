class_name Player
extends CharacterBody2D

const ACCEL = 4000
const DECEL = 35
const MAX_SPEED = 175
const DODGE_SPEED = 500
const DODGE_DECELERATION = 100


const stored_skull_scene = preload("res://scenes/game_object/stored_skull/stored_skull.tscn")
const skeleton_scene = preload("res://scenes/game_object/skeleton/skeleton.tscn")
const skeleton_launch_area = preload("res://scenes/game_object/player/skeleton_launch_area.tscn")


@onready var skull_pickup_area: Area2D = $SkullPickupArea
@onready var stored_skulls: Node2D = $StoredSkulls
@onready var center_marker: Marker2D = $CenterMarker2D
@onready var hitbox: Area2D = $Hitbox
@onready var dodge_timer: Timer = $DodgeTimer

var dodge_direction = Vector2.ZERO


func _ready():
	skull_pickup_area.area_entered.connect(on_skull_pickup_area_entered)
	hitbox.area_entered.connect(on_hitbox_area_entered)


func _process(delta: float):
	if (Input.is_action_just_pressed("dodge") && dodge_timer.is_stopped()):
		dodge_timer.start()
		dodge_direction = get_movement_vector().normalized()
		velocity = dodge_direction * DODGE_SPEED
	
	if (!dodge_timer.is_stopped()):
		process_dodge(delta)
	else:
		process_normal(delta)


func process_normal(delta: float):
	var movement_vector = get_movement_vector()
	velocity += movement_vector * ACCEL * delta
	velocity = velocity.limit_length(MAX_SPEED)
	
	if (is_equal_approx(movement_vector.length_squared(), 0)):
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-DECEL * delta))
		
	move_and_slide()
	
	if (Input.is_action_just_pressed("place") && stored_skulls.get_child_count() > 0):
		summon_skeleton()
		
	if (Input.is_action_just_pressed("click")):
		create_launch_area()


func process_dodge(_delta: float):
	if (velocity.length() < MAX_SPEED):
		dodge_timer.stop()

	var percent_through_dodge = 1 - (dodge_timer.time_left / dodge_timer.wait_time)
	
	var speed_difference = DODGE_SPEED - MAX_SPEED
	velocity = dodge_direction * (DODGE_SPEED - (speed_difference * percent_through_dodge))
	
	move_and_slide()


func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func summon_skeleton():
	var skeleton = skeleton_scene.instantiate()
	skeleton.global_position = global_position + global_position.direction_to(get_global_mouse_position()) * 16
	get_parent().add_child(skeleton)
	
	if (stored_skulls.get_child_count() > 0):
		stored_skulls.get_child(0).queue_free()


func create_launch_area():
	var area = skeleton_launch_area.instantiate()
	area.direction = (get_global_mouse_position() - center_marker.global_position).normalized()
	area.global_position = center_marker.global_position
	get_parent().add_child(area)


func on_skull_pickup_area_entered(area: Area2D):
	area.owner.queue_free()
	stored_skulls.add_child(stored_skull_scene.instantiate())


func on_hitbox_area_entered(_area: Area2D):
	await get_tree().physics_frame
	get_tree().change_scene_to_file("res://scenes/main.tscn")
