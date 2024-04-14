class_name Bullet
extends CharacterBody2D


const SPEED = 150


@onready var area: Area2D = $Area2D


func _ready():
	area.area_entered.connect(on_area_entered)


func _process(_delta):
	move_and_slide()
	
	if (get_last_slide_collision() != null):
		destroy()


func start(direction: Vector2):
	velocity = direction * SPEED


func destroy():
	queue_free()


func on_area_entered(_area: Area2D):
	destroy()
