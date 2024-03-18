extends Node2D


func _ready():
	# Play main theme
	Global.play_music.emit(123)
