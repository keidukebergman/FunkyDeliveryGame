extends CharacterBody3D

@export_group("Control inertia")
@export var throttle_increase_per_second: float = 2;
var throttle = 0; 

@export_group("Base Flight Parameters")
var min_speed: float = 1
@export var max_level_speed: float = 60.0
@export var engine_power: float = 20.0
@export var base_drag: float = 5.0

@export_group("Hover")
@export var max_hover_speed = 30;
@export var target_hover_speed = 0;
@export var min_hover_speed = -30;
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
var actual_hover_speed: Vector3
var actual_movement_speed: Vector3
var actual_fall_speed: Vector3
var hover_speed: Vector3

@export_group("Force Interpolation")
var idle_movement_speed_interpolation: float = 10
@export var normal_movement_speed_interpolation: float = 70
@export var boost_movement_speed_interpolation: float = 120

var hovering:bool = false;
var hover_mode_pressed = false;
var stall_speed = 50;


func _process(delta: float) -> void:
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
	if !hovering:
		calculate_flight_physics(delta)
	else:
		handle_hovering(delta);
	velocity = actual_movement_speed + actual_fall_speed + actual_hover_speed;
	move_and_slide()

func calculate_flight_physics(delta: float) -> void:
	var forward_dir = -transform.basis.z
	var pitch_attitude = forward_dir.dot(Vector3.UP)
	var acceleration = throttle * engine_power
	var hover_speed = up_direction * throttle 
	var interpolation_speed = boost_movement_speed_interpolation if throttle == 2 else (normal_movement_speed_interpolation if throttle == 1 else idle_movement_speed_interpolation)
	var flight_speed = forward_dir * throttle * max_level_speed;
	actual_movement_speed = actual_movement_speed.move_toward(flight_speed, delta * interpolation_speed);
	
	if (actual_movement_speed.length() < stall_speed):
		print("Stalling: ", actual_movement_speed.length(), " : ", stall_speed)
		actual_fall_speed.y = max(actual_fall_speed.y, -99999)
		actual_fall_speed.y = clamp(actual_fall_speed.y, -200, 0)
		actual_fall_speed -= delta * 12 * Vector3.UP * clamp((stall_speed - actual_movement_speed.length())/stall_speed, 0, 1);
	else:
		actual_fall_speed = actual_fall_speed.move_toward(Vector3.ZERO, normal_movement_speed_interpolation*delta)    
	
func handle_hovering(delta:float) -> void:
	actual_movement_speed = actual_movement_speed.move_toward(Vector3.ZERO, idle_movement_speed_interpolation*delta)
	var hover_throttle = max_hover_speed if throttle == 2 else (target_hover_speed if throttle == 1 else min_hover_speed)  
	var ams_projected_up = actual_movement_speed.project(transform.basis.y)
	actual_movement_speed -= ams_projected_up
	ams_projected_up = ams_projected_up.move_toward(Vector3.ZERO, hover_force * delta)
	
	var updot = Vector3.UP.dot(transform.basis.y)
	var l_hov = -50 * transform.basis.y.project(Vector3.LEFT)
	var f_hov = -50 * transform.basis.y.project(Vector3.FORWARD)
	
	var tilt_loss = -5 * (clamp(1-updot, 0, 1))
	if updot < 0.2:
		start_falling(delta, -(updot-0.2))
	else:
		actual_fall_speed = actual_fall_speed.move_toward(Vector3.ZERO, normal_movement_speed_interpolation*delta)    
	
	var hover_speed = (tilt_loss * Vector3.UP + hover_throttle*transform.basis.y + l_hov*Vector3.LEFT + f_hov*Vector3.FORWARD)
	actual_hover_speed = actual_hover_speed.move_toward(hover_speed, hover_force*delta)
	
func start_falling(delta:float, factor:float) -> void:
	actual_fall_speed.y = max(actual_fall_speed.y, -99999)
	actual_fall_speed.y = clamp(actual_fall_speed.y, -200, 0)
	actual_fall_speed -= delta * factor * 12 * Vector3.UP * clamp((stall_speed - actual_movement_speed.length())/stall_speed, 0, 1);

	
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
