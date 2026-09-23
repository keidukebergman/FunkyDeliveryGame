extends Node3D

@export var movement_speed = 10
@export var rotation_speed = 30
@export var targeting_module:TargetingModule

func _process(delta: float) -> void:
	var target_position = targeting_module.get_linear_target_position()
	var dir: Vector3 = target_position - global_position
	var yaw = atan2(-dir.x, -dir.z)
	var pitch = atan2(dir.y, Vector2(dir.x, dir.z).length()) 
	rotation = rotation.move_toward(Vector3(pitch, yaw, 0.0), delta * deg_to_rad(rotation_speed))
	position -= transform.basis.z * delta * movement_speed
