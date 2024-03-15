extends CanvasLayer


@onready var label = $GUI/Label


func update_text(wallphase_count: int, has_wallrun: bool, has_timejump: bool):
	label.text = "Dash Count: %s
Wallrun Available? %s
Timejump Available? %s" % [wallphase_count, "Yes" if has_wallrun else "No", "Yes" if has_timejump else "No"]
