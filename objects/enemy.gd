extends CharacterBody2D

const SPEED: float = 120.0
@export var is_aggressive = false
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var is_seeking = false
var player_last_seen;

func _physics_process(_delta):
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	var target = $%Player

	if is_seeking:
		player_last_seen = target.global_position
		nav.target_position = player_last_seen

	if not nav.is_navigation_finished() || is_aggressive || is_seeking:

		var next_path_position: Vector2 = nav.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()	

func is_in_line_of_sight(target: Node) -> bool:
	if target == null:
		return false
	var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position) 
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	print("RESULT: ", result)
	if result:
		print("COLLIDER: ", result["collider"])
		var collider = result["collider"]
		if collider == target:
			return true
	
	return false

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
