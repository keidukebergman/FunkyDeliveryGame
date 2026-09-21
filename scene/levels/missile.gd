extends Node3D

@export var movement_speed = 10
@export var targeting_module:TargetingModule

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_position = targeting_module.get_linear_target_position()
	
	var dir: Vector3 = target_position - global_position
	var yaw = atan2(-dir.x, -dir.z)
	var pitch = atan2(dir.y, Vector2(dir.x, dir.z).length()) 
	rotation = Vector3(pitch, yaw, 0.0)
	position -= transform.basis.z * delta * movement_speed
