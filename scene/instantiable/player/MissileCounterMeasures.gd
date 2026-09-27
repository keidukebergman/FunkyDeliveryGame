class_name MissileCountermeasure extends Node3D

@export var missile_target:MissileTarget
@export var cm_timeout: float = 5
@export var flare: PackedScene
@export var flare_timeout:float = 0.4
@export var flares:int = 5

func deploy():
	var flrs = [flares]
	for n in flares:
		var flr = flare.instantiate() as Node3D
		get_tree().get_root().add_child(flr)
		flr.global_position = global_position
		flr.global_rotation = global_rotation
		flrs[n] = flr
	for missile in missile_target.tracking_missiles:
		missile.set_target(flrs[randi_range(0, flares-1)])
