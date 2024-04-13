class_name Enemy
extends CharacterBody2D

@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer: Timer = $AttackTimer

const bullet_scene = preload("res://scenes/game_object/bullet/bullet.tscn")


func _ready():
	attack_timer.timeout.connect(on_attack_timer_timeout)
	hitbox.area_entered.connect(on_area_entered)
	attack_timer.start_random()

	
func attack():
	var bullet = bullet_scene.instantiate() as Bullet
	var player = get_tree().get_first_node_in_group("player") as Player
	
	var foreground = get_tree().get_first_node_in_group("foreground")
	bullet.global_position = global_position
	foreground.add_child(bullet)
	
	var direction = global_position.direction_to(player.center_marker.global_position)
	bullet.start(direction)


func on_area_entered(other_area: Area2D):
	var skeleton = other_area.owner as Skeleton
	if (skeleton == null):
		return
		
	queue_free()


func on_attack_timer_timeout():
	attack_timer.start_random()
	attack()
