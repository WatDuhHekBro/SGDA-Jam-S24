extends MarginContainer


func _on_button_player_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("yeet")


func _on_button_options_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("asdf")
