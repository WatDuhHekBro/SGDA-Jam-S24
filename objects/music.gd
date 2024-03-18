extends Node


@onready var intro = $IntroTheme
@onready var main = $MainTheme


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.play_music.connect(change_music)


func change_music(song):
	# Jank Shitcode++
	if song == 123:
		intro.stop()
		main.play()
	elif song == 420:
		main.stop()
		intro.play()
