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
		missile_indicator_instance.queue_free()

func _process(delta: float) -> void:
	for missile in missile_indicator_mapping.keys():
		var missile_indicator_instance = missile_indicator_mapping.get(missile)
		missile_indicator_instance.visible = true
		if !missile:
			missile_indicator_instance.queue_free()
			continue
		missile_indicator
		var missile_position = missile.position
		var indicator = missile_indicator_mapping.get(missile) as Node3D
		indicator.look_at(missile_position, Vector3.UP)
