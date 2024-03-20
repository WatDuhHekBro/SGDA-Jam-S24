extends CharacterBody2D

const DirUtils = preload("res://objects/utils/directions.gd")

@export var speed: float = 80.0
@export var acceleration: float = 12.0
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var target = $%Player
@onready var player_spotted_sfx = $PlayerSpottedSFX
var anim
var is_seeking = false
var target_last_seen;
var lost_sight = true;

func _ready() -> void:
	$PlayerDetected.visible = false
	
	# Randomized textures
	decide_villager()

func decide_villager():
	# Hide all villagers
	for i in range($Villagers.get_child_count()):
		$Villagers.get_child(i).visible = false
	
	var random = randi() % $Villagers.get_child_count()

	anim = $Villagers.get_child(random)
	$Villagers.get_child(random).visible = true


func _physics_process(_delta):
	await get_tree().physics_frame
	if target == null:
		return;

	if is_seeking:
		target_last_seen = target.global_position
		nav.set_target_position(target_last_seen)

	if nav.is_navigation_finished() && $ReactionTime.time_left == 0:
		$PlayerDetected.visible = false
		lost_sight = true
		velocity = Vector2.ZERO
		return;
	
	if not nav.is_navigation_finished() || not lost_sight:
		var next = to_local(nav.get_next_path_position())
		var desired_velocity = velocity + next.normalized() * acceleration
		desired_velocity = desired_velocity.limit_length(speed)
		velocity = desired_velocity
	
	move_and_slide()

	check_animation()

func is_line_of_sight() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	var result = space_state.intersect_ray(query)
	if result:
		return result.collider == target
	return false

func _on_player_entered(_body):
	if is_line_of_sight():
		if lost_sight:
			player_spotted_sfx.play()
		target_last_seen = target.global_position
		lost_sight = false
		$PlayerDetected.visible = true
		$ReactionTime.start()

func _on_player_exited(_body):
	is_seeking = false

func _on_kill_player_entered(_body: Node2D):
	$PlayerKilledSFX.play()
	$%Player.kill()

func check_animation():
	var dotted = velocity.dot(DirUtils.direction_to_vector(DirUtils.Directions.UP))
	
	if dotted > 0:
		anim.play("forward")
	elif dotted < 0:
		anim.play("backward")
	
	if velocity.x > 0:
		anim.flip_h = true
	elif velocity.x < 0:
		anim.flip_h = false


func _on_reaction_time_timeout():
	is_seeking = true
