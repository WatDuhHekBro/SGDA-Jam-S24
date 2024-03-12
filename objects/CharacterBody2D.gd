extends CharacterBody2D


const SPEED = 125.0
const SPEED_WALLPHASE = 300.0
const ANGLE_X = cos(deg_to_rad(27))
const ANGLE_Y = sin(deg_to_rad(27))
# Toggle these by collecting items in-game, set to true for debug purposes
var wallphase_count = 1
var can_wallrun = true
var can_timejump = true
# moar vars
enum WallphaseDirection {UP, DOWN, LEFT, RIGHT}
var stored_direction = WallphaseDirection.RIGHT
var is_currently_wallphasing = false
var is_currently_wallrunning = false
# References
@onready var timer_timejump = $TimerTimejump
@onready var timer_wallphase_timeout = $TimerWallphaseTimeout
@onready var collision = $CollisionShape2D
var stored_position_x = 0
var stored_position_y = 0


func _physics_process(delta):
	if is_currently_wallphasing || is_currently_wallrunning:
		collision.set_deferred("disabled", true)
		
		# Messy code, needs refactor
		if stored_direction == WallphaseDirection.LEFT:
			velocity.x = -1 * SPEED_WALLPHASE * ANGLE_X
			velocity.y = -1 * SPEED_WALLPHASE * ANGLE_Y
		elif stored_direction == WallphaseDirection.RIGHT:
			velocity.x = SPEED_WALLPHASE * ANGLE_X
			velocity.y = SPEED_WALLPHASE * ANGLE_Y
		elif stored_direction == WallphaseDirection.DOWN:
			velocity.x = -1 * SPEED_WALLPHASE * ANGLE_X
			velocity.y = -1 * SPEED_WALLPHASE * -ANGLE_Y
		elif stored_direction == WallphaseDirection.UP:
			velocity.x = SPEED_WALLPHASE * ANGLE_X
			velocity.y = SPEED_WALLPHASE * -ANGLE_Y
	else:
		var direction_x = Input.get_axis("ui_left", "ui_right")
		var direction_y = Input.get_axis("ui_down", "ui_up")
		
		# Octodirectional movement
		if direction_x && direction_y:
			# Right + Up
			if direction_x == 1 && direction_y == 1:
				velocity.x = SPEED
				velocity.y = move_toward(velocity.y, 0, SPEED)
			# Left + Down
			elif direction_x == -1 && direction_y == -1:
				velocity.x = -SPEED
				velocity.y = move_toward(velocity.y, 0, SPEED)
			# Right + Down
			elif direction_x == 1 && direction_y == -1:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.y = SPEED
			# Left + Up
			elif direction_x == -1 && direction_y == 1:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.y = -SPEED
		# Horizontal only
		elif direction_x:
			velocity.x = direction_x * SPEED * ANGLE_X
			velocity.y = direction_x * SPEED * ANGLE_Y
			
			if direction_x < 0:
				stored_direction = WallphaseDirection.LEFT
			elif direction_x > 0:
				stored_direction = WallphaseDirection.RIGHT
		# Vertical only
		elif direction_y:
			velocity.x = direction_y * SPEED * ANGLE_X
			velocity.y = direction_y * SPEED * -ANGLE_Y
			
			if direction_y < 0:
				stored_direction = WallphaseDirection.DOWN
			elif direction_y > 0:
				stored_direction = WallphaseDirection.UP
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
		
		# Abilities/Actions
		if wallphase_count > 0 && Input.is_action_just_released("action-wallphase"):
			is_currently_wallphasing = true
			wallphase_count -= 1
			timer_wallphase_timeout.start()
			print("wallphase")
		
		if can_wallrun && Input.is_action_just_released("action-wallrun"):
			is_currently_wallrunning = true
			can_wallrun = false
			timer_wallphase_timeout.start()
			print("wallrun")
		
		if can_timejump && Input.is_action_just_released("action-timejump") && timer_timejump.time_left <= 0:
			stored_position_x = position.x
			stored_position_y = position.y
			timer_timejump.start()
			can_timejump = false
			print("start timejump")

	move_and_slide()


func _on_timer_timejump_timeout():
	position.x = stored_position_x
	position.y = stored_position_y
	print("execute timejump after 5s")


# Selective Collisions: https://forum.godotengine.org/t/how-can-i-enable-and-disable-collisions-from-script/20731/2

func _on_auxiliary_collision_area_body_entered(body):
	if body.name == "Walls":
		timer_wallphase_timeout.stop()
		print("stop wallphase timeout")
		
		if is_currently_wallrunning:
			print("wallrun start")
			is_currently_wallrunning = false
	
	print('[Wallphase Enter] ', body.name)


func _on_auxiliary_collision_area_body_exited(body):
	if body.name == "Walls":
		# First exit of walls on wallphase should end
		# Exiting a wall should stop the wallrun
		# Make sure to call set_deferred() instead of setting directly, causes issues otherwise
		collision.set_deferred("disabled", false)
		is_currently_wallphasing = false
	
	print('[Wallphase Exit] ', body.name)


# Case if player wallphases into nowhere
func _on_timer_wallphase_timeout_timeout():
	collision.set_deferred("disabled", false)
	is_currently_wallphasing = false
	is_currently_wallrunning = false
	print("wallphase safety cancel")
