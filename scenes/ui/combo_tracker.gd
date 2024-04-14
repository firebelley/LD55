extends HBoxContainer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shake_animation_player: AnimationPlayer = $ShakeAnimationPlayer
@onready var decay_timer: Timer = $DecayTimer
@onready var label: Label = %Label

var count: int = 0

func _ready():
	GlobalThings.enemy_killed.connect(on_enemy_killed)
	decay_timer.timeout.connect(on_decay_timeout)


func update_display():
	if (count >= 10):
		shake_animation_player.play("shake")
		label.modulate = Color("d14444")
	elif (count >= 5):
		label.modulate = Color("#e3c72d")
	else:
		shake_animation_player.play("RESET")
		label.modulate = Color.WHITE
		
	label.text = "x" + str(count)


func bounce():
	if (animation_player.is_playing()):
		animation_player.seek(0, true)
	animation_player.play("bounce")


func on_enemy_killed():
	count += 1
	update_display()
	
	if (!decay_timer.is_stopped()):
		decay_timer.stop()
	decay_timer.start()
	bounce()


func on_decay_timeout():
	count = 0
	update_display()
	bounce()
