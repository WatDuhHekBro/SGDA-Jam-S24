extends CharacterBody2D


const SPEED = 100.0


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x = Input.get_axis("ui_left", "ui_right")
	var direction_y = Input.get_axis("ui_down", "ui_up")
	
	if direction_x:
		velocity.x = direction_x * SPEED * cos(deg_to_rad(30))
		velocity.y = direction_x * SPEED * sin(deg_to_rad(30))
		print('x\' = ', velocity.x)
		print('y\' = ', velocity.y)
	elif direction_y:
		velocity.x = direction_y * SPEED * cos(deg_to_rad(-30))
		velocity.y = direction_y * SPEED * sin(deg_to_rad(-30))
		print('x = ', velocity.x)
		print('y = ', velocity.y)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
