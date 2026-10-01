class_name VisualWarningSystem extends Node3D

@export var missile_target:MissileTarget
@export var missile_indicator:PackedScene
var missile_indicator_mapping:Dictionary[Missile, Node3D]

func _ready() -> void:
	missile_target.missile_detected.connect(on_missile_lock)
	missile_target.missile_lost.connect(on_missile_lost)

func on_missile_lock(missile:Missile):
	var missile_indicator_instance = missile_indicator.instantiate()
	add_child(missile_indicator_instance)
	missile_indicator_instance.position = Vector3.ZERO
	missile_indicator_instance.rotation = Vector3.ZERO
	missile_indicator_mapping.set(missile, missile_indicator_instance)
	missile_indicator_instance.visible = false

func on_missile_lost(missile:Missile):
	var missile_indicator_instance = missile_indicator_mapping.get(missile)
	missile_indicator_mapping.erase(missile)
	if missile_indicator_instance:
		missile_indicator_instance.free()

func _process(delta: float) -> void:
	for missile in missile_indicator_mapping.keys():
		var indicator = missile_indicator_mapping[missile] as Node3D
		indicator.look_at(missile.global_position, Vector3.UP)
		indicator.visible = true
		var scalefactor = 1 - clamp(global_position.distance_to(missile.global_position)/500, 0, 0.7)
		indicator.get_child(0).scale = Vector3(scalefactor, scalefactor, scalefactor)
