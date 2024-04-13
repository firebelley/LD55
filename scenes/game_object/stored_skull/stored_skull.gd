extends Node2D


@onready var sprite: Sprite2D = %Sprite2D


func _process(delta):
	sprite.global_rotation = 0.0
