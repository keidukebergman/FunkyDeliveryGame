extends RigidBody3D

@export_group("Control inertia")
@export var throttle_increase_per_second: float = 2;
var throttle = 0; 

@export_group("Base Flight Parameters")
var min_speed: float = 1
@export var max_level_speed: float = 60.0
@export var engine_power: float = 20.0
@export var base_drag: float = 5.0

@export_group("Hover")
@export var max_hover_speed = 10;
@export var target_hover_speed = 0;
@export var min_hover_speed = -10;
var hover_interpolation_speed = 10;
var hover_force = 40;

@export_group("Rotation Speeds")
@export var no_thrust_control_factor = 1.5
@export var boost_control_factor = 0.7
@export var pitch_speed: float = 1.5
@export var pitch_inertia: float = 1.2
@export var roll_speed: float = 2.5
@export var roll_inertia: float = 1.2
@export var yaw_speed: float = 0.75
@export var yaw_inertia: float = 1.1

var current_pitch_speed = 0
var current_roll_speed = 0
var current_yaw_speed = 0

var current_speed: float = 30.0
var actual_movement_speed: Vector3
var hover_speed: Vector3

@export_group("Force Interpolation")
var idle_movement_speed_interpolation: float = 10
@export var normal_movement_speed_interpolation: float = 70
@export var boost_movement_speed_interpolation: float = 120

var hovering:bool = false;
var hover_mode_pressed = false;

func _process(delta: float) -> void:
	print("Hovering: ", hovering)
	var throttle_input = Input.get_axis("throttle_down", "throttle_up");
	if Input.is_action_pressed("throttle_up") && Input.is_action_pressed("throttle_down"):
		if hover_mode_pressed == false:
			hover_mode_pressed = true
			hovering = !hovering
	else:
		throttle = throttle_input + 1 
		throttle = clamp(throttle, 0, 2)
		hover_mode_pressed = false
		
func _physics_process(delta: float) -> void:
	handle_rotation(delta)
	calculate_flight_physics(delta)
	linear_velocity = actual_movement_speed;

@export var vertical_grip = 50.0    # N per (m/s) of error along the body's up axis

func calculate_flight_physics(delta: float) -> void:
	var forward_dir := -transform.basis.z
	var up_axis := transform.basis.y
	var hover_target_speed = max_hover_speed if throttle == 2 else (target_hover_speed if throttle == 1 else min_hover_speed)
	if hovering:
		throttle = 0
	var force := Vector3.ZERO
	# Thrust along the nose
	force += forward_dir * throttle * engine_power
	# Linear drag 
	var drag_coefficient = engine_power / max_level_speed
	var v_up = actual_movement_speed.dot(up_axis)

	var v_planar = actual_movement_speed - up_axis * v_up
	force -= v_planar * drag_coefficient

	var target_v_up = hover_target_speed if hovering else 0.0
	var grip = minf(vertical_grip, mass / delta)
	var vertical_force = (target_v_up - v_up) * grip
	if hovering:
		vertical_force = clampf(vertical_force, -hover_force, hover_force)
	force += up_axis * vertical_force

	# Integrate: a = F / m
	actual_movement_speed += (force / mass) * delta
		
	
func handle_rotation(delta: float) -> void:
	var pitch_input = Input.get_axis("pitch_down", "pitch_up")
	var roll_input = -Input.get_axis("roll_right", "roll_left")
	var yaw_input = Input.get_axis("yaw_right", "yaw_left")
	
	var control_factor = 1 if throttle == 1 else (boost_control_factor if throttle == 2 else no_thrust_control_factor)
	
	current_pitch_speed = move_toward(current_pitch_speed, pitch_input*pitch_speed*control_factor, delta*pitch_inertia);
	current_roll_speed = move_toward(current_roll_speed, roll_input*roll_speed*control_factor, delta*roll_inertia);
	current_yaw_speed = move_toward(current_yaw_speed, yaw_input*yaw_speed*control_factor, delta*yaw_inertia);
	
	var attitude_pitch_adjustment = abs(transform.basis.z.dot(Vector3.UP)/5)
	var roll_pitch_adjustment = clamp(get_roll_adjustment()/10, 0, 0.2)
	var speed_pitch_adjustment = clamp(actual_movement_speed.project(transform.basis.y).length() / 1000, 0, 1);
	
	if hovering:
		rotate_object_local(Vector3.RIGHT, current_pitch_speed * pitch_speed * delta)
		rotate_object_local(Vector3.FORWARD, current_roll_speed * roll_speed * delta)
		rotate_object_local(Vector3.UP, current_yaw_speed * yaw_speed * delta)
	else:
		rotate_object_local(Vector3.RIGHT, (current_pitch_speed * pitch_speed + speed_pitch_adjustment + attitude_pitch_adjustment + roll_pitch_adjustment) * delta)
		rotate_object_local(Vector3.FORWARD, current_roll_speed * roll_speed * delta)
		rotate_object_local(Vector3.UP, current_yaw_speed * yaw_speed * delta)
	


func get_roll_adjustment() -> float:
	var forward = -global_transform.basis.z
	var local_up = global_transform.basis.y
	var world_up_projected = (Vector3.UP - forward * Vector3.UP.dot(forward)).normalized()
	var dot = local_up.dot(world_up_projected)
	dot = clamp(dot, 0.0, 1.0)
	
	return (1.0 - dot)
