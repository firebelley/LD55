class_name Player
extends CharacterBody2D

const ACCEL = 4000
const DECEL = 35
const MAX_SPEED = 160
const DODGE_SPEED = 800
const DODGE_DECELERATION = 500


const stored_skull_scene = preload("res://scenes/game_object/stored_skull/stored_skull.tscn")
const skeleton_scene = preload("res://scenes/game_object/skeleton/skeleton.tscn")
const skeleton_launch_area = preload("res://scenes/game_object/player/skeleton_launch_area.tscn")
const push_particles = preload("res://scenes/effect/push_particles.tscn")


@onready var skull_pickup_area: Area2D = $SkullPickupArea
@onready var center_marker: Marker2D = $CenterMarker2D
@onready var hitbox: Area2D = $Hitbox
@onready var dodge_timer: Timer = $DodgeTimer
@onready var hitbox_collision_shape: CollisionShape2D = %HitboxCollisionShape
@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dodge_animation_player: AnimationPlayer = $DodgeAnimationPlayer

var dodge_direction = Vector2.ZERO


func _ready():
	dodge_timer.timeout.connect(on_dodge_timer_timeout)
	skull_pickup_area.area_entered.connect(on_skull_pickup_area_entered)
	hitbox.area_entered.connect(on_hitbox_area_entered)


func _process(delta: float):
	if (Input.is_action_just_pressed("dodge") && dodge_timer.is_stopped()):
		hitbox_collision_shape.disabled = true
		dodge_timer.start()
		dodge_direction = get_movement_vector().normalized()
		play_dodge()
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
	
	var scale_mod = 1
	if (get_global_mouse_position().x < global_position.x):
		scale_mod = -1
	visuals.scale.x = scale_mod
	
	if (is_equal_approx(movement_vector.length_squared(), 0)):
		animation_player.play("RESET")
	else:
		animation_player.play("run")
	
	move_and_slide()
		
	if (Input.is_action_just_pressed("click")):
		create_launch_area()


func process_dodge(_delta: float):
	if (velocity.length() < MAX_SPEED):
		dodge_timer.stop()
		hitbox_collision_shape.disabled = false
		if dodge_animation_player.is_playing():
			dodge_animation_player.play("RESET")

	var percent_through_dodge = 1 - (dodge_timer.time_left / dodge_timer.wait_time)
	
	var speed_difference = DODGE_SPEED - MAX_SPEED
	velocity = dodge_direction * (DODGE_SPEED - (speed_difference * percent_through_dodge))
	
	move_and_slide()


func get_movement_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func summon_skeleton(at_position: Vector2):
	var skeleton = skeleton_scene.instantiate()
	skeleton.global_position = at_position
	get_parent().add_child(skeleton)


func create_launch_area():
	var foreground = get_tree().get_first_node_in_group("foreground")
	
	var area = skeleton_launch_area.instantiate()
	area.direction = (get_global_mouse_position() - center_marker.global_position).normalized()
	area.global_position = center_marker.global_position
	foreground.add_child(area)
	
	var particles = push_particles.instantiate() as Node2D
	particles.global_position = area.global_position + area.direction * 16
	particles.rotation = area.direction.angle()
	foreground.add_child(particles)
	
	play_dodge()


func on_skull_pickup_area_entered(area: Area2D):
	area.owner.queue_free()
	summon_skeleton.call_deferred((area.owner as Node2D).global_position)


func on_hitbox_area_entered(_area: Area2D):
	await get_tree().physics_frame
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func on_dodge_timer_timeout():
	hitbox_collision_shape.disabled = false


func play_dodge():
	if dodge_animation_player.is_playing():
		dodge_animation_player.seek(0, true)
	dodge_animation_player.play("dodge")
