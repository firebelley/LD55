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

const bullet_scene = preload("res://scenes/game_object/bullet/bullet.tscn")

var is_attacking = false
var current_target_position = Vector2.ZERO


func _ready():
	attack_timer.timeout.connect(on_attack_timer_timeout)
	windup_timer.timeout.connect(on_windup_timer_timeout)
	hitbox.area_entered.connect(on_area_entered)
	attack_timer.start_random()


func _process(delta):
	acquire_target_position()
	var movement_direction = global_position.direction_to(current_target_position)
	
	if (!is_attacking):
		velocity += movement_direction * ACCEL * delta
	else:
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-DECEL * delta))
		
	velocity = velocity.limit_length(MAX_SPEED)
		
	move_and_slide()


func attack():
	var bullet = bullet_scene.instantiate() as Bullet
	var player = get_tree().get_first_node_in_group("player") as Player
	
	var foreground = get_tree().get_first_node_in_group("foreground")
	bullet.global_position = global_position
	foreground.add_child(bullet)
	
	var direction = global_position.direction_to(player.center_marker.global_position)
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
		
	queue_free()


func on_attack_timer_timeout():
	is_attacking = true
	windup_timer.start()


func on_windup_timer_timeout():
	attack()
	attack_timer.start_random()
	is_attacking = false
