extends CharacterBody2D

@export var speed: float = 40.0
@export var is_aggressive = false
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var target = $%Player
var is_seeking = false
var target_last_seen;

func _ready() -> void:
	nav.velocity_computed.connect(Callable(_on_velocity_computed))

func _physics_process(_delta):
	if is_seeking:
		target_last_seen = target.global_position
		nav.set_target_position(target_last_seen)

	if not nav.is_navigation_finished() || is_aggressive || is_seeking:
		var new_velocity = global_position.direction_to(nav.get_next_path_position()) * speed
		_on_velocity_computed(new_velocity)


	move_and_slide()	

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func _on_detection_area_body_entered(body):
	print("SEEK FOR ", body.name)
	if body.name == "Player":
		print("SEEK TRUE")
		is_seeking = true


func _on_detection_area_body_exited(body):
	if body.name == "Player":
		print("SEEK FALSE")
		is_seeking = false


func _on_kill_area_body_entered(body):
	if body.name == "Player":
		body.kill()
