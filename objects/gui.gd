extends CanvasLayer


@onready var label = $GUI/Label
@onready var gameover = $GUI/GameOver
@onready var timer = $Timer
var is_gameover = false


func update_text(wallphase_count: int, has_wallrun: bool, has_timejump: bool):
	label.text = "Dash Count: %s
Wallrun Available? %s
Timejump Available? %s" % [wallphase_count, "Yes" if has_wallrun else "No", "Yes" if has_timejump else "No"]


func set_game_over(status: bool):
	is_gameover = status
	
	if status:
		timer.start()
		gameover.visible = true


func _on_timer_timeout():
	gameover.visible = !gameover.visible
