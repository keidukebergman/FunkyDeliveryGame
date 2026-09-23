extends Node3D
class_name Turret

@export var target:CharacterBody3D
@export var turret:Node3D
@export var rotation_speed = 30
@export var targeting_module:TargetingModule
@export var projectile:PackedScene
@export var firing_timeout = 0.6
@export var airburst:bool = true
@export var forward_offset:float = 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_position = targeting_module.get_linear_target_position()
	var dir: Vector3 = target_position - global_position
	var yaw = atan2(-dir.x, -dir.z)
	var pitch = atan2(dir.y, Vector2(dir.x, dir.z).length()) 
	turret.rotation = Vector3(pitch, yaw, 0.0)
	
	firing_timeout -= delta
	if firing_timeout <= 0:
		firing_timeout = 0.03
		fire_projectile()

func fire_projectile():
	var projinstance = projectile.instantiate() as Bullet
	add_child(projinstance)
	projinstance.global_position = turret.global_position
	projinstance.global_rotation = turret.global_rotation + Vector3(deg_to_rad(randf_range(-2, 2)), deg_to_rad(randf_range(-2, 2)), deg_to_rad(randf_range(-2, 2)))
	if airburst:
		var t = targeting_module.get_linear_intercept_time()
		projinstance.lifetime = clamp(t+randf_range(-0.5, 0.5), 0, 10)
