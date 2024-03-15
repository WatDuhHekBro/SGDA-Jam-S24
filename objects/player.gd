extends CharacterBody2D

const DirUtils = preload("res://objects/utils/directions.gd")

const SPEED = 125.0
const SPEED_WALLPHASE = 300.0
const ANGLE_X = cos(deg_to_rad(27))
const ANGLE_Y = sin(deg_to_rad(27))
# Dedicated walls to wallphase/wallrun through, special collision checks
const NAME_WALLS = "Layer1"
# Dedicated outer bounds of the map, prevents the player from running off into the distance
const NAME_BOUNDS = "Layer1Bounds"
# Toggle these by collecting items in-game, set to true for debug purposes
var wallphase_count = 0
var can_wallrun = false
var can_timejump = false
# moar vars
var stored_direction = DirUtils.Directions.ZERO
var is_currently_wallphasing = false
var is_currently_wallrunning = false
# References
@onready var timer_timejump = $TimerTimejump
@onready var timer_wallphase_timeout = $TimerWallphaseTimeout
@onready var collision = $CollisionShape2D
@onready var gui = $%GUI
var stored_position_x = 0
var stored_position_y = 0


func _ready():
	gui.update_text(wallphase_count, can_wallrun, can_timejump)


func _physics_process(_delta):
	if is_currently_wallphasing || is_currently_wallrunning:
		collision.set_deferred("disabled", true)
		
		# Messy code, needs refactor
		for dir in DirUtils.DIRECTIONS :
			if stored_direction == dir:
				velocity = DirUtils.direction_to_vector(dir) * SPEED_WALLPHASE
				break;
	else:
		var rectangular_vector = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
		var iso_direction = DirUtils.rectangular_vector_to_direction(rectangular_vector)
		var iso_vector = DirUtils.direction_to_vector(iso_direction)
		stored_direction = iso_direction

		check_animation()
		
		velocity = iso_vector * SPEED

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
		
		if can_timejump && Input.is_action_just_released("action-timejump") && timer_timejump.time_left <= 0 && !is_currently_wallphasing && !is_currently_wallrunning:
			stored_position_x = position.x
			stored_position_y = position.y
			timer_timejump.start()
			can_timejump = false
			print("start timejump")
		
		gui.update_text(wallphase_count, can_wallrun, can_timejump)
	
	move_and_slide()

func check_animation():
	var dotted = velocity.dot(DirUtils.direction_to_vector(DirUtils.Directions.UP))
	if dotted > 0:
		$AnimatedSprite2D.play("foward")
	elif dotted < 0:
		$AnimatedSprite2D.play("backward")

	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false

func _on_timer_timejump_timeout():
	position.x = stored_position_x
	position.y = stored_position_y
	print("execute timejump after 5s")


# Selective Collisions: https://forum.godotengine.org/t/how-can-i-enable-and-disable-collisions-from-script/20731/2

func _on_auxiliary_collision_area_body_entered(body):
	if body.name == NAME_WALLS:
		timer_wallphase_timeout.stop()
		print("stop wallphase timeout")
		
		if is_currently_wallrunning:
			print("wallrun start")
			is_currently_wallrunning = false
	elif body.name == NAME_BOUNDS:
		collision.set_deferred("disabled", false)
		is_currently_wallphasing = false
		is_currently_wallrunning = false
		print("wallphase safety cancel (bounds)")
	#elif body.name == ""
	
	print('[Wallphase Enter] ', body.name)


func _on_auxiliary_collision_area_body_exited(body):
	if body.name == NAME_WALLS:
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


func _on_auxiliary_collision_area_area_entered(area):
	if area.name.begins_with("CrystalWallphase"):
		wallphase_count += area.refills
	if area.name.begins_with("CrystalWallrun"):
		can_wallrun = true
	if area.name.begins_with("CrystalTimejump"):
		can_timejump = true
	
	gui.update_text(wallphase_count, can_wallrun, can_timejump)
	
	# Delete item
	area.queue_free()


func kill():
	print("KILL player call")
	queue_free()
	gui.set_game_over(true)
