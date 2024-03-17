extends CharacterBody2D

const DirUtils = preload("res://objects/utils/directions.gd")

@export var speed: float = 50.0
@export var is_aggressive = false
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var target = $%Player
@onready var anim = $AnimatedSprite2D
var is_seeking = false
var target_last_seen;

func _ready() -> void:
	nav.velocity_computed.connect(Callable(_on_velocity_computed))
	
	# Randomized textures
	print(anim.sprite_frames)

func _physics_process(_delta):
	if nav.is_navigation_finished():
		_on_velocity_computed(Vector2(0, 0))
	if is_seeking && is_line_of_sight():
		target_last_seen = target.global_position
		nav.set_target_position(target_last_seen)
	
	if not nav.is_navigation_finished() || is_aggressive || is_seeking:
		var new_velocity = global_position.direction_to(nav.get_next_path_position()) * speed
		_on_velocity_computed(new_velocity)
	
	check_animation()

func is_line_of_sight() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	var result = space_state.intersect_ray(query)
	if result:
		return result.collider == target
	return false

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func _on_player_entered(body):
	is_seeking = true

func _on_player_exited(body):
	is_seeking = false

func _on_kill_player_entered(body: Node2D):
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
