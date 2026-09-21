extends Node3D
class_name Turret

@export var target:CharacterBody3D
@export var turret:Node3D
@export var targeting_module:TargetingModule


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_position = targeting_module.get_linear_target_position()
	
	var dir: Vector3 = to_local(target_position) - position
	var yaw = atan2(-dir.x, -dir.z)
	var pitch = atan2(dir.y, Vector2(dir.x, dir.z).length()) 
	turret.rotation = Vector3(pitch, yaw, 0.0)
