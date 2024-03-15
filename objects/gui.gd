extends CanvasLayer


@onready var wallphase_counter = $GUI/Wallphase/Label
@onready var wallrun_status = $GUI/Wallrun/On
@onready var timejump_status = $GUI/Timejump/On
@onready var gameover = $GameOver
@onready var timer = $Timer
var is_gameover = false


func update_text(wallphase_count: int, has_wallrun: bool, has_timejump: bool):
	wallphase_counter.text = "%s" % wallphase_count
	wallrun_status.visible = has_wallrun
	timejump_status.visible = has_timejump


func set_gameover(status: bool):
	is_gameover = status
	
	if status:
		timer.start()
		gameover.visible = true


func _on_timer_timeout():
	gameover.visible = !gameover.visible


func _input(event):
	if event.is_action_pressed("menu-start") and is_gameover:
		get_tree().reload_current_scene()
