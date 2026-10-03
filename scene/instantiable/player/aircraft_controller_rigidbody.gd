class_name PlayerAircraftControllerRig extends RigidBody3D

@export var data = CombatantData.new()

@export_group("Control inertia")
@export var throttle_increase_per_second: float = 2.0
var throttle: float = 1.0
var throttle_level: float = 1.0

@export_group("Base Flight Parameters")
@export var max_level_speed: float = 60.0
@export var boost_speed_multiplier: float = 1.5
@export var stall_speed: float = 40.0
@export var forward_drag: float = 0.005
@export var side_drag: float = 0.03
@export var vertical_drag: float = 0.01

@export_group("Hover")
@export var hover_high_target_velocity = 10
@export var hover_low_target_velocity = -10
@export var hover_low_thrust_factor: float = 0.5
@export var hover_high_thrust_factor: float = 1.5
@export var hover_vertical_drag: float = 0.16
@export var hover_horizontal_drag: float = 0.5
@export var hover_max_force:float = 10000
var is_landing = false

@export_group("Rotation Speeds")
@export var pitch_speed: float = 1.2
@export var roll_speed: float = 2.5
@export var yaw_speed: float = 0.8
@export var pitch_response: float = 3.0
@export var roll_response: float = 3.0
@export var yaw_response: float = 3.0
@export_range(0.0, 1.0) var min_control_authority: float = 0.15
@export var full_control_speed: float = 40.0

var hovering: bool = false
var hover_mode_pressed = false

@export_group("Collision")
@export var crash_speed_threshold: float = 20.0
var _prev_velocity = Vector3.ZERO

@export_group("Local References")
@export var countermeasures: MissileCountermeasure
@export var missile_warning_system: MissileTarget
@export var landing_gear: Area3D


func _ready() -> void:
	linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	linear_damp = 0.0
	angular_damp = 0.0
	can_sleep = false
	contact_monitor = true
	max_contacts_reported = 4


func _process(_delta: float) -> void:
	var throttle_input = Input.get_axis("throttle_down", "throttle_up")
	if Input.is_action_just_pressed("hover_switch"):
		hovering = not hovering
	else:
		throttle = clampf(throttle_input + 1.0, 0.0, 2.0)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	check_crash(state)
	throttle_level = move_toward(throttle_level, throttle, throttle_increase_per_second * state.step)
	apply_rotation_torque(state)
	if hovering:
		apply_hover_forces(state)
	else:
		apply_flight_forces(state)
	_prev_velocity = state.linear_velocity

func _throttle_curve(level: float, at_0: float, at_1: float, at_2: float) -> float:
	if level <= 1.0:
		return lerpf(at_0, at_1, level)
	return lerpf(at_1, at_2, level - 1.0)


func apply_flight_forces(state: PhysicsDirectBodyState3D) -> void:
	var gravity = state.total_gravity.length()
	var local_velocity = basis.transposed() * state.linear_velocity
	var cruise_thrust = forward_drag * max_level_speed * max_level_speed
	var boost_speed = max_level_speed * boost_speed_multiplier
	var boost_thrust = forward_drag * boost_speed * boost_speed
	var thrust = _throttle_curve(throttle_level, 0.0, cruise_thrust, boost_thrust)
	var thrust_accel = Vector3(0.0, 0.0, -thrust) 

	var drag_accel = 5 * -Vector3(
		side_drag * local_velocity.x * absf(local_velocity.x),
		vertical_drag * local_velocity.y * absf(local_velocity.y),
		forward_drag * local_velocity.z * absf(local_velocity.z))

	if throttle == 0:
		drag_accel /= 3

	var forward_airspeed = maxf(-local_velocity.z, 0.0)
	var lift_ratio = clampf(pow(forward_airspeed / stall_speed, 2.0), 0.0, 1.0)
	var lift_accel = Vector3(0.0, gravity * lift_ratio, 0.0)

	var total_local_accel = thrust_accel + drag_accel + lift_accel
	state.apply_central_force(basis * total_local_accel * mass)

@export var vertical_kp: float = 4.0
@export var hover_min_force: float = -2000
@export var hover_deviation_tolerance: float = 0.45

func apply_hover_forces(state: PhysicsDirectBodyState3D) -> void:
	var vel: Vector3 = state.linear_velocity
	var up: Vector3 = transform.basis.y.normalized()
	
	var speed_up: float = vel.dot(Vector3.UP)
	var vel_local_up: Vector3 = up * speed_up
	var vel_horizontal: Vector3 = vel - vel_local_up;

	var gravity_along_down: float = -state.total_gravity.dot(up)
	var target_speed_up: float = 0.0

	match throttle:
		0.0: 
			target_speed_up = hover_low_target_velocity
		1.0: 
			target_speed_up = 0.0
		2.0: 
			target_speed_up = hover_high_target_velocity

	var accel_up: float = (target_speed_up - speed_up) * vertical_kp
	var required_force: float = mass * (gravity_along_down + accel_up)

	var thrust: Vector3 = clampf(required_force, hover_min_force, hover_max_force) * up

	var drag_accel: Vector3 = -(vel_horizontal * hover_horizontal_drag + vel_local_up * hover_vertical_drag)

	state.apply_central_force(thrust + drag_accel * mass)


func apply_rotation_torque(state: PhysicsDirectBodyState3D) -> void:
	var pitch_input = Input.get_axis("pitch_down", "pitch_up")
	var roll_input = -Input.get_axis("roll_right", "roll_left")
	var yaw_input = Input.get_axis("yaw_right", "yaw_left")

	var control_factor = 1.0
	if not hovering:
		var airspeed_ratio = clampf(state.linear_velocity.length() / full_control_speed, 0.0, 1.0)
		control_factor = lerpf(min_control_authority, 1.0, airspeed_ratio)

	var target = Vector3(
		pitch_input * pitch_speed,
		yaw_input * yaw_speed,
		-roll_input * roll_speed) * control_factor
	if hovering and is_landing:
		target = Vector3.ZERO

	var local_angular_velocity = basis.transposed() * state.angular_velocity
	var error = target - local_angular_velocity
	var angular_accel_local = Vector3(
		error.x * pitch_response,
		error.y * yaw_response,
		error.z * roll_response)

	var angular_accel_world = basis * angular_accel_local
	var torque = state.inverse_inertia_tensor.inverse() * angular_accel_world
	state.apply_torque(torque)


func on_landing_gear_collision() -> void:
	pass


func check_crash(state: PhysicsDirectBodyState3D) -> void:
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		var impact_speed = absf(_prev_velocity.dot(normal))
		if impact_speed > crash_speed_threshold:
			print("DIED! COLLISION!")
			return
