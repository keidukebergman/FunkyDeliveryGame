extends CharacterBody3D
@export_group("Base Flight Parameters")
@export var min_speed: float = 15.0
@export var max_level_speed: float = 60.0
@export var absolute_max_speed: float = 110.0 # Top speed achievable only in a dive
@export var engine_power: float = 20.0
@export var base_drag: float = 5.0

@export_group("Gravity & Aerodynamics")
@export var gravity_pull: float = 25.0 # Speed gained/lost from steep dives/climbs
@export var climb_penalty_mult: float = 1.5 # Extra drag when climbing steeply

@export_group("Rotation Speeds")
@export var pitch_speed: float = 1.5
@export var pitch_inertia: float = 1.2
@export var roll_speed: float = 2.5
@export var roll_inertia: float = 1.2
@export var yaw_speed: float = 0.75
@export var yaw_inertia: float = 1.1

@export var current_pitch_speed = 0
@export var current_roll_speed = 0
@export var current_yaw_speed = 0

var current_speed: float = 30.0
func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	calculate_flight_physics(delta)

	# Calculate velocity vector along local forward axis (-Z)
	var forward_dir = -transform.basis.z
	velocity = forward_dir * current_speed

	move_and_slide()

func calculate_flight_physics(delta: float) -> void:
	var forward_dir = -transform.basis.z
	
	var pitch_attitude = forward_dir.dot(Vector3.UP)
	
	var throttle_input = Input.get_axis("throttle_down", "throttle_up")
	var acceleration = throttle_input * engine_power
	
	var dynamic_max_speed = max_level_speed
		
	current_speed = clamp(current_speed, min_speed, dynamic_max_speed)

func handle_rotation(delta: float) -> void:
	var pitch_input = Input.get_axis("pitch_down", "pitch_up")
	var roll_input = Input.get_axis("roll_right", "roll_left")
	var yaw_input = Input.get_axis("yaw_right", "yaw_left")
	
	current_pitch_speed = move_toward(current_pitch_speed, pitch_input*pitch_speed, delta*pitch_inertia);
	current_roll_speed = move_toward(current_roll_speed, roll_input*roll_speed, delta*roll_inertia);
	current_yaw_speed = move_toward(current_yaw_speed, yaw_input*yaw_speed, delta*yaw_inertia);
	
	rotate_object_local(Vector3.RIGHT, current_pitch_speed * pitch_speed * delta)
	rotate_object_local(Vector3.FORWARD, current_roll_speed * roll_speed * delta)
	rotate_object_local(Vector3.UP, current_yaw_speed * yaw_speed * delta)
