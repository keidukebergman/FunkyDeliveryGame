extends Node3D 
class_name TargetingModule

@export var target:CharacterBody3D
@export var aim_at_next_pos:bool = false
@export var projectile_speed_factor: float = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_linear_intercept_time(offset = Vector3.ZERO) -> float:
	var to_target = target.global_position + offset - global_position
	
	var a = 1 - projectile_speed_factor * projectile_speed_factor
	var b = 2.0 * to_target.dot(target.velocity)
	var c = to_target.dot(to_target)
	
	var t = -1.0
	if abs(a) < 0.0001:
		if abs(b) > 0.0001:
			t = -c / b
	else:
		var discriminant = b * b - 4.0 * a * c
		if discriminant >= 0.0:
			var sqrt_disc = sqrt(discriminant)
			var t1 = (-b + sqrt_disc) / (2.0 * a)
			var t2 = (-b - sqrt_disc) / (2.0 * a)
			if t1 > 0 and t2 > 0:
				t = min(t1, t2)
			elif t1 > 0:
				t = t1
			elif t2 > 0:
				t = t2
	return t

func get_linear_target_position(offset = Vector3.ZERO) -> Vector3:
	if aim_at_next_pos == false:
		return target.global_position
	var t = get_linear_intercept_time()
	if t < 0.0:
		return target.global_position + offset
	
	return target.global_position + target.velocity * t
