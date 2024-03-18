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
@onready var gui = %GUI
@onready var change_direction_sfx = $ChangeDirectionSFX
@onready var wallphase0_sfx = $Wallphase0SFX
@onready var wallphase1_sfx = $Wallphase1SFX
@onready var wallphase2_sfx = $Wallphase2SFX
@onready var player_killed_sfx = $PlayerKilledSFX
var stored_position_x = 0
var stored_position_y = 0
var last_input = Vector2(0, 0)


func _ready():
	if gui != null:
		gui.update_text(wallphase_count, can_wallrun, can_timejump)


func _physics_process(_delta):
	if is_currently_wallphasing || is_currently_wallrunning:
		collision.set_deferred("disabled", true)
		
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
			wallphase0_sfx.play()
			is_currently_wallphasing = true
			wallphase_count -= 1
			timer_wallphase_timeout.start()
		
		if can_wallrun && Input.is_action_just_released("action-wallrun"):
			wallphase1_sfx.play()
			is_currently_wallrunning = true
			can_wallrun = false
			timer_wallphase_timeout.start()
		
		if can_timejump && Input.is_action_just_released("action-timejump") && timer_timejump.time_left <= 0 && !is_currently_wallphasing && !is_currently_wallrunning:
			$Shadow.emitting = true
			wallphase2_sfx.play()
			stored_position_x = position.x
			stored_position_y = position.y
			timer_timejump.start()
			can_timejump = false
		
		gui.update_text(wallphase_count, can_wallrun, can_timejump)
	
	move_and_slide()

func close_enough_vectors(a: Vector2, b: Vector2, epsilon) -> bool:
	return abs(a.x - b.x) < epsilon && abs(a.y - b.y) < epsilon

func check_animation():
	var dotted = velocity.dot(DirUtils.direction_to_vector(DirUtils.Directions.UP))
	
	if dotted > 0:
		$AnimatedSprite2D.play("forward")
	elif dotted < 0:
		$AnimatedSprite2D.play("backward")


	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false

func _on_timer_timejump_timeout():
	position.x = stored_position_x
	position.y = stored_position_y


# Selective Collisions: https://forum.godotengine.org/t/how-can-i-enable-and-disable-collisions-from-script/20731/2

func _on_wall_entered(body):
	timer_wallphase_timeout.stop()
	print("stop wallphase timeout")
		
	if is_currently_wallrunning:
		print("wallrun start")
		is_currently_wallrunning = false
	
	print('[Wallphase Enter] ', body.name)


func _on_wall_exited(body):
	# First exit of walls on wallphase should end
	# Exiting a wall should stop the wallrun
	# Make sure to call set_deferred() instead of setting directly, causes issues otherwise
	collision.set_deferred("disabled", false)
	is_currently_wallphasing = false
	
	print('[Wallphase Exit] ', body.name)

func _on_bound_entered(body):
	print('[Bound Enter] ', body.name)
	# Case if player wallphases into nowhere
	timer_wallphase_timeout.stop()
	print("stop wallphase timeout")
	collision.set_deferred("disabled", false)
	is_currently_wallphasing = false
	is_currently_wallrunning = false
	print("wallphase safety cancel")

# Case if player wallphases into nowhere
func _on_timer_wallphase_timeout_timeout():
	collision.set_deferred("disabled", false)
	is_currently_wallphasing = false
	is_currently_wallrunning = false
	$Shadow.emitting = false
	print("wallphase safety cancel")


func _on_pickup_entered(area):
	# Very janky way of moving to the next level, select which level it is
	if area.name == "EscapeArea":
		get_tree().change_scene_to_file(area.teleport_to)
	
	# Ability pickups
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
	queue_free()
	gui.set_gameover(true)
