extends CanvasLayer


@onready var wallphase_counter = $Hotbar/Wallphase/Label
@onready var wallrun_status = $Hotbar/Wallrun/On
@onready var timejump_status = $Hotbar/Timejump/On
@onready var gameover = $GameOver
var is_gameover = false

func _ready():
	visible = true


func update_text(wallphase_count: int, has_wallrun: bool, has_timejump: bool):
	wallphase_counter.text = "%s" % wallphase_count
	wallrun_status.visible = has_wallrun
	timejump_status.visible = has_timejump


func set_gameover(status: bool):
	is_gameover = status
	gameover.visible = status


func _input(event):
	if event.is_action_pressed("menu-start") and is_gameover:
		get_tree().reload_current_scene()
