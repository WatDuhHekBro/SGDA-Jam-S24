extends CanvasLayer


const positions = [Vector2(731, 317), Vector2(795, 382), Vector2(795, 449), Vector2(884, 574)]
var cursor_position = 0

enum States {TITLE, MENU}
var current_state = States.TITLE

@onready var title = $Screens/Title
@onready var cursor = $Cursor


func _input(event):
	if event.is_action_pressed("ui_up"):
		cursor_position -= 1
		
		if cursor_position < 0:
			cursor_position = positions.size() - 1
		
		cursor.position = positions[cursor_position]
	
	if event.is_action_pressed("ui_down"):
		cursor_position += 1
		
		if cursor_position >= positions.size():
			cursor_position = 0
		
		cursor.position = positions[cursor_position]
	
	if event.is_action_pressed("menu-start"):
		match current_state:
			States.TITLE:
				title.visible = false
				cursor.visible = true
				current_state = States.MENU
			States.MENU:
				match cursor_position:
					0:
						get_tree().change_scene_to_file("res://maps/storytime.tscn")
					1:
						print("options")
					2:
						print("credits")
					3:
						get_tree().quit()


func _on_newgame_mouse_entered():
	cursor_position = 0
	cursor.position = positions[cursor_position]

func _on_options_mouse_entered():
	cursor_position = 1
	cursor.position = positions[cursor_position]

func _on_credits_mouse_entered():
	cursor_position = 2
	cursor.position = positions[cursor_position]

func _on_exit_mouse_entered():
	cursor_position = 3
	cursor.position = positions[cursor_position]
