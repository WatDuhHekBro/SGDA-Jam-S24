extends CharacterBody2D

const SPEED: float = 150.0
#@export var is_aggressive = false
@onready var nav: NavigationAgent2D = $NavigationAgent2D
#var is_seeking = false

func _physics_process(_delta):
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	#if is_aggressive || is_seeking:
	
	nav.target_position = $%Player.position
	
	if nav.is_navigation_finished():
		return
	
	var next_path_position: Vector2 = nav.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * SPEED
	
	move_and_slide()


func _on_detection_area_body_entered(body):
	#print("SEEK FOR ", body.name)
	if body.name == "Player":
		print("SEEK TRUE")
		#is_seeking = true


func _on_detection_area_body_exited(body):
	if body.name == "Player":
		print("SEEK FALSE")
		#is_seeking = false


func _on_kill_area_body_entered(body):
	if body.name == "Player":
		body.kill()
