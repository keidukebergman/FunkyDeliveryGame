class_name Missile extends RigidBody3D

@export var projectile_attack_handler: ProjectileAttackHandler

@export var movement_speed = 10
@export var rotation_speed:float = 1.0
@export var targeting_module:TargetingModule
@export var target:Node3D
var tracking_loss_value = 0.98
@export var should_PN_target = true
@export var rotation_loss = 0.4
@export var rotation_loss_distance = 30
@export var dot_rotation_loss_guard = 0.5
@export var dot_rotation_loss_max = 0.6
@export var dot_loss_power = 1.25

var initialized = false

func _ready() -> void:
	initialized = true
	projectile_attack_handler.applied_attack.connect(_on_hit)

func set_target(target:Node3D):
	self.target = target
	targeting_module.target = target
	missile_velocity = -transform.basis.z * movement_speed
var nav_constant: float = 4 #3-5

var missile_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if initialized:
		if target:
			if should_PN_target:
				_PN_targeting(delta)
				return
			var target_position = targeting_module.get_linear_target_position()
			var dir: Vector3 = (target_position - global_position).normalized()
			if dir.length_squared() > 0.0:
				var current_quat: Quaternion = global_transform.basis.get_rotation_quaternion()
				var target_quat: Quaternion = Basis.looking_at(dir, Vector3.UP).get_rotation_quaternion()
				var new_quat: Quaternion = current_quat.slerp(target_quat, delta * deg_to_rad(rotation_speed))
				global_transform.basis = Basis(new_quat)
			if (target.global_position - global_position).dot(-transform.basis.z) < tracking_loss_value:
				print("forgor 💀")
				target = null
		linear_velocity = -transform.basis.z * movement_speed

func _PN_targeting(delta: float) -> void:
	if not target:
		return

	var target_pos: Vector3 = target.global_position
	var target_vel: Vector3 = target.velocity  
	var los: Vector3 = target_pos - global_position      
	var los_len_sq: float = los.length_squared()

	if los_len_sq > 0.001:
		var rel_vel: Vector3 = target_vel - missile_velocity 
		var closing_vel: float = -rel_vel.dot(los.normalized()) 
		var omega: Vector3 = los.cross(rel_vel) / los_len_sq
		var vel_dir: Vector3 = missile_velocity.normalized() if missile_velocity.length() > 0.01 else -transform.basis.z
		var accel_cmd: Vector3 = nav_constant * closing_vel * omega.cross(vel_dir)
		missile_velocity += accel_cmd * delta
		missile_velocity = missile_velocity.normalized() * movement_speed  
		
		var dist = global_position.distance_to(target.global_position)
		var actual_rotation_speed = rotation_speed * clamp(dist/rotation_loss_distance, 1 - rotation_loss, 1)
		actual_rotation_speed *= clamp(pow(clamp(los.dot(target_vel)+dot_rotation_loss_guard,0,1), dot_loss_power), 1-dot_rotation_loss_max, 1)       
		if missile_velocity.length_squared() > 0.001:
			var current_quat: Quaternion = global_transform.basis.get_rotation_quaternion()
			var target_quat: Quaternion = Basis.looking_at(missile_velocity.normalized(), Vector3.UP).get_rotation_quaternion()
			var new_quat: Quaternion = current_quat.slerp(target_quat, delta * actual_rotation_speed)
			global_transform.basis = Basis(new_quat)
	
	linear_velocity = -transform.basis.z * movement_speed

	if (target.global_position - global_position).dot(-transform.basis.z) < tracking_loss_value:
		target = null


func _on_hit():
	print("hit!")
	queue_free()
