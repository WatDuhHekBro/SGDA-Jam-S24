extends Node


signal play_music(song: int)


func _input(event):
	if event.is_action_pressed("menu-reset"):
		get_tree().change_scene_to_file("res://maps/offgameplay/menu.tscn")
