extends Node2D

@onready var hitbox: Area2D = $Hitbox


var explosion_scene = preload("res://scenes/game_object/enemy_mine/mine_explosion.tscn")


func _ready():
	hitbox.area_entered.connect(on_area_entered)


func explode():
	var explosion = explosion_scene.instantiate() as Node2D
	explosion.global_position = global_position
	get_tree().get_first_node_in_group("foreground").add_child(explosion)

	queue_free()


func on_area_entered(_other_area: Area2D):
	explode.call_deferred()
