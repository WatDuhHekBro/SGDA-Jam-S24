extends Sprite2D


const OFFSET_BOUNDS = 3
var is_increasing = true


func _on_timer_timeout():
	if is_increasing:
		if offset.y >= OFFSET_BOUNDS:
			is_increasing = false
		else:
			offset.y += 1
	else:
		if offset.y <= -OFFSET_BOUNDS:
			is_increasing = true
		else:
			offset.y -= 1
