class_name Bullet extends Node3D

@export var projectile_speed = 400
@export var lifetime = 6.0
@export var on_destroy_instance: PackedScene

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		on_lifetime_timeout()
	
func _physics_process(delta: float) -> void:
	position -= transform.basis.z * delta * projectile_speed

func on_lifetime_timeout():
	queue_free()
	if on_destroy_instance:
		var instance = on_destroy_instance.instantiate() as Node3D
		get_tree().get_root().add_child(instance)
		instance.global_position = global_position
		instance.global_rotation = global_rotation
