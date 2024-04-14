class_name Enemy
extends CharacterBody2D

const ACCEL = 500
const MAX_SPEED = 50
const BACKOFF_DISTANCE = 100
const DECEL = 10
const MIN_TARGET_DISTANCE = 100
const MAX_TARGET_DISTANCE = 200


@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer
@onready var windup_timer: Timer = $WindupTimer
@onready var target_acquisition_timer: Timer = $TargetAcquisitionTimer
@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arm_right: Sprite2D = %ArmRight
@onready var barrel_marker: Marker2D = %BarrelMarker2D
@onready var centerMarker: Marker2D = $CenterMarker2D


const death_particles_scene = preload("res://scenes/effect/enemy_death_particles.tscn")
const bullet_scene = preload("res://scenes/game_object/bullet/bullet.tscn")
const blaster_particles_scene = preload("res://scenes/effect/blaster_particles.tscn")


@export var disable_ai = false
var is_attacking = false
var current_target_position = Vector2.ZERO


func _ready():
	attack_timer.timeout.connect(on_attack_timer_timeout)
	windup_timer.timeout.connect(on_windup_timer_timeout)
	hitbox.area_entered.connect(on_area_entered)
	
	if (!disable_ai):
		attack_timer.start_random()


func _process(delta):
	if (disable_ai || (animation_player.current_animation == "spawn" && animation_player.is_playing())):
		return
	acquire_target_position()
	var movement_direction = global_position.direction_to(current_target_position)
	
	var player = get_tree().get_first_node_in_group("player") as Player
	if (player != null):
		var old_rotation = arm_right.rotation
		arm_right.look_at(player.center_marker.global_position)
		var new_rotation = arm_right.rotation
		arm_right.rotation = lerp_angle(old_rotation, new_rotation, 1.0 - exp(-3 * delta))
	
	if (!is_attacking):
		if (animation_player.current_animation != "run"):
			animation_player.play("run")
		velocity += movement_direction * ACCEL * delta
	else:
		if (animation_player.assigned_animation != "RESET"):
			animation_player.play("RESET")
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-DECEL * delta))

		
	velocity = velocity.limit_length(MAX_SPEED)
	
	if (player != null):
		var scale_mod = 1
		if (player.global_position.x < global_position.x):
			scale_mod = -1
		visuals.scale.x = scale_mod
		
	move_and_slide()


func attack():
	var bullet = bullet_scene.instantiate() as Bullet
	
	var foreground = get_tree().get_first_node_in_group("foreground")
	bullet.global_position = barrel_marker.global_position
	foreground.add_child(bullet)
	
	var direction = Vector2.RIGHT.rotated(arm_right.global_rotation)
	
	var particles = blaster_particles_scene.instantiate() as Node2D
	foreground.add_child(particles)
	particles.global_position = bullet.global_position
	particles.rotation = direction.angle()
	
	bullet.start(direction)


func acquire_target_position():
	var player = get_tree().get_first_node_in_group("player") as Player
	if (!target_acquisition_timer.is_stopped() || player == null):
		return
	
	var movement_direction = global_position.direction_to(player.global_position)
	var distance_to_player = player.global_position.distance_to(global_position)
	
	if (distance_to_player < BACKOFF_DISTANCE):
		movement_direction *= -1
		
	movement_direction = movement_direction.rotated(randf_range(-TAU/8, TAU/8))
	
	var target_distance = randf_range(MIN_TARGET_DISTANCE, MAX_TARGET_DISTANCE)
	current_target_position = global_position + (movement_direction * target_distance)
		
	target_acquisition_timer.start_random()


func on_area_entered(other_area: Area2D):
	var skeleton = other_area.owner as Skeleton
	if (skeleton == null):
		return
	
	var death_particles = death_particles_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("entities").add_child(death_particles)
	death_particles.global_position = centerMarker.global_position
	queue_free()
	
	GlobalThings.shake_camera()
	GlobalThings.emit_enemy_killed()


func on_attack_timer_timeout():
	is_attacking = true
	windup_timer.start()


func on_windup_timer_timeout():
	attack()
	attack_timer.start_random()
	is_attacking = false
