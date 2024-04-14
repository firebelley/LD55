class_name MessageBanner
extends CanvasLayer

signal finished


const warning_color = Color("#d14444")


@onready var incoming_message: Label = %IncomingMessage
@onready var success_message: Label = %SuccessMessage
@onready var color_rect: ColorRect = %ColorRect


func play_warning():
	success_message.visible = false
	incoming_message.visible = true
	color_rect.color = warning_color
	

func play_success():
	success_message.visible = true
	incoming_message.visible = false


func finish():
	finished.emit()
	queue_free()
