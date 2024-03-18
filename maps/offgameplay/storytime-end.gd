extends Node2D


const BOOK_STATES = ["turn1to2", "turn2to3"]
const BOOK_STATES_TEXT = ["Start text", "This is some moar sample text.", "THE END"]
var book_states_index = 0
@onready var book = $Book
@onready var label = $Label


func _ready():
	label.text = BOOK_STATES_TEXT[0]
	# Play intro theme
	Global.play_music.emit(420)


# Returns true if done flipping pages
func flip_page():
	# Progress between states
	if book_states_index < BOOK_STATES.size():
		var state = BOOK_STATES[book_states_index]
		book_states_index += 1
		book.play(state)
		return false
	else:
		return true


func _on_timer_timeout():
	label.visible_characters += 1


func _input(event):
	if event.is_action_pressed("menu-start"):
		label.visible = false
		flip_page()


func _on_book_animation_finished():
	# Start the next label
	label.visible = true
	label.text = BOOK_STATES_TEXT[book_states_index]
	label.visible_characters = 0
