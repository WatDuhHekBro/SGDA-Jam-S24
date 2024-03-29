extends Node2D


const BOOK_STATES = ["turn1to2", "turn2to3"]
const BOOK_STATES_TEXT = [[
		"Not so long ago, there were only two races", 
		"One of light, One of Darkness"
	], [
		"For unknown reasons, a third race appeared", 
		"despised by both light and shadow but belonging to both"
	], [
		"Rumor speaks of a realm where shadow and light can coexist",
		"One brave little ghost is trying to escape there"
	]];
var book_states_index = 0
@onready var book = $Book
@onready var labels = [$FirstPageLabel, $SecondPageLabel]
var label


func _ready():
	label = 0
	labels[label].text = BOOK_STATES_TEXT[0][0]

# Returns true if done flipping pages
func flip_page():

	# Progress between states
	if book_states_index < BOOK_STATES.size():
		$PageTurnSFX.play()
		var state = BOOK_STATES[book_states_index]
		book_states_index += 1
		book.play(state)
		return false
	else:
		return true


func _on_timer_timeout():
	if labels[label].visible_ratio < 1:
		labels[label].visible_ratio += 0.1
	elif label == labels.size() - 1:
		return;
	else:
		start_next_label()

func _input(event):
	if event.is_action_pressed("menu-start"):
		for i in range(labels.size()):
			labels[i].visible = false
		var is_done_flipping_pages = flip_page()
		
		if is_done_flipping_pages:
			get_tree().change_scene_to_file("res://maps/tutorial/tutorial-1.tscn")


func _on_book_animation_finished():
	start_next_label()

func start_next_label():
	label = (label + 1) % labels.size()
	labels[label].visible = true
	# current book side increments by 1 every time we flip a page
	labels[label].text = BOOK_STATES_TEXT[book_states_index][label]
	labels[label].visible_ratio = 0
