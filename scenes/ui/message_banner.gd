class_name MessageBanner
extends CanvasLayer

signal finished


const warning_color = Color("#d14444")


@onready var incoming_message: Label = %IncomingMessage
@onready var success_message: Label = %SuccessMessage
@onready var death_message: Label = %DeathMessage
@onready var color_rect: ColorRect = %ColorRect

func _ready():
	incoming_message.visible = false
	success_message.visible = false
	death_message.visible = false

func play_warning():
	incoming_message.visible = true
	color_rect.color = warning_color
	

func play_success():
	success_message.visible = true


func play_death():
	death_message.visible = true
	color_rect.color = warning_color


func finish():
	finished.emit()
	queue_free()
