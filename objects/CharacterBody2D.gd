extends CharacterBody2D


const SPEED = 125.0
const SPEED_WALLPHASE = 200.0
# Toggle these by collecting items in-game, set to true for debug purposes
var wallphase_count = 1
var can_wallrun = true
var can_timejump = true
# moar vars
enum WallphaseDirection {UP, DOWN, LEFT, RIGHT}
var stored_direction = WallphaseDirection.RIGHT
var is_currently_wallphasing = false
# References
@onready var timer = $Timer
@onready var collision = $CollisionShape2D
var stored_position_x = 0
var stored_position_y = 0


func _physics_process(delta):
	if is_currently_wallphasing:
		collision.disabled = true
		
		# Messy code, needs refactor
		if stored_direction == WallphaseDirection.LEFT:
			velocity.x = -1 * SPEED * cos(deg_to_rad(30))
			velocity.y = -1 * SPEED * sin(deg_to_rad(30))
		elif stored_direction == WallphaseDirection.RIGHT:
			velocity.x = SPEED * cos(deg_to_rad(30))
			velocity.y = SPEED * sin(deg_to_rad(30))
		elif stored_direction == WallphaseDirection.DOWN:
			velocity.x = -1 * SPEED * cos(deg_to_rad(-30))
			velocity.y = -1 * SPEED * sin(deg_to_rad(-30))
		elif stored_direction == WallphaseDirection.UP:
			velocity.x = SPEED * cos(deg_to_rad(-30))
			velocity.y = SPEED * sin(deg_to_rad(-30))
	else:
		var direction_x = Input.get_axis("ui_left", "ui_right")
		var direction_y = Input.get_axis("ui_down", "ui_up")
		
		if direction_x:
			velocity.x = direction_x * SPEED * cos(deg_to_rad(30))
			velocity.y = direction_x * SPEED * sin(deg_to_rad(30))
			
			if direction_x < 0:
				stored_direction = WallphaseDirection.LEFT
			elif direction_x > 0:
				stored_direction = WallphaseDirection.RIGHT
		elif direction_y:
			velocity.x = direction_y * SPEED * cos(deg_to_rad(-30))
			velocity.y = direction_y * SPEED * sin(deg_to_rad(-30))
			
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
			print("wallphase")
		
		if can_wallrun && Input.is_action_just_released("action-wallrun"):
			print("wallrun")
		
		if can_timejump && Input.is_action_just_released("action-timejump") && timer.time_left <= 0:
			stored_position_x = position.x
			stored_position_y = position.y
			timer.start()
			print("start timejump")

	move_and_slide()


func _on_timer_timeout():
	position.x = stored_position_x
	position.y = stored_position_y
	print("execute timejump after 5s")


func _on_auxiliary_collision_area_body_entered(body):
	print('[Wallphase Enter] ', body.name)


func _on_auxiliary_collision_area_body_exited(body):
	print('[Wallphase Exit] ', body.name)
