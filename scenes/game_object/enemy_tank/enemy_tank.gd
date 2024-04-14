class_name EnemyTank
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
@onready var arm_left: Sprite2D = %ArmLeft
@onready var barrel_marker: Marker2D = %BarrelMarker2D
@onready var stun_timer: Timer = $StunTimer

const bullet_scene = preload("res://scenes/game_object/bullet/bullet.tscn")

var is_attacking = false
var current_target_position = Vector2.ZERO


func _ready():
	attack_timer.timeout.connect(on_attack_timer_timeout)
	windup_timer.timeout.connect(on_windup_timer_timeout)
	hitbox.area_entered.connect(on_area_entered)
	attack_timer.start_random()


func _process(delta):
	if (!stun_timer.is_stopped()):
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-DECEL * delta))
		move_and_slide()
		return
		
	acquire_target_position()
	var player = get_tree().get_first_node_in_group("player") as Player
	var movement_direction = global_position.direction_to(current_target_position)
	
	if (player != null):
		var old_rotation = arm_left.rotation
		arm_left.look_at(player.center_marker.global_position)
		var new_rotation = arm_left.rotation
		arm_left.rotation = lerp_angle(old_rotation, new_rotation, 1.0 - exp(-3 * delta))
	
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
	if (!stun_timer.is_stopped()):
		return

	var bullet = bullet_scene.instantiate() as Bullet
	
	var foreground = get_tree().get_first_node_in_group("foreground")
	bullet.global_position = barrel_marker.global_position
	foreground.add_child(bullet)
	
	var direction = Vector2.RIGHT.rotated(arm_left.global_rotation)
	
	bullet.start(direction)


func acquire_target_position():
	if (!target_acquisition_timer.is_stopped()):
		return
	
	var player = get_tree().get_first_node_in_group("player") as Player
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
	
	GlobalThings.shake_camera()
	
	if (!stun_timer.is_stopped()):
		queue_free()
	else:
		stun_timer.start()
		animation_player.play("RESET")
		animation_player.play("stun")


func on_attack_timer_timeout():
	is_attacking = true
	windup_timer.start()


func on_windup_timer_timeout():
	attack()
	attack_timer.start_random()
	is_attacking = false
