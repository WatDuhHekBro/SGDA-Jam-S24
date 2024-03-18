extends CanvasLayer


@onready var wallphase_counter = $Hotbar/Wallphase/Label
@onready var wallrun_status = $Hotbar/Wallrun/On
@onready var timejump_status = $Hotbar/Timejump/On
@onready var gameover = $GameOver
@onready var pause_menu = $PausedGame
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


func _on_button_pressed():
	get_tree().paused = true
	pause_menu.visible = true


func _on_resume_pressed():
	get_tree().paused = false
	pause_menu.visible = false

func _on_main_menu_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	get_tree().change_scene_to_file("res://maps/offgameplay/menu.tscn")
