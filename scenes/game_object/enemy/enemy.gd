class_name Enemy
extends CharacterBody2D

@onready var hitbox: Area2D = $Hitbox


func _ready():
	hitbox.area_entered.connect(on_area_entered)
	

func on_area_entered(other_area: Area2D):
	var skeleton = other_area.owner as Skeleton
	if (skeleton == null):
		return
		
	queue_free()
