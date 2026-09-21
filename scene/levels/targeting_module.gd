extends Node3D 
class_name TargetingModule

@export var target:CharacterBody3D
@export var aim_at_next_pos:bool = false
var projectile_speed_factor: float = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_linear_target_position () -> Vector3:
	if aim_at_next_pos == false:
		return target.global_position
	var t = (target.global_position - global_position).length()/projectile_speed_factor
	return target.global_position + target.velocity * t
