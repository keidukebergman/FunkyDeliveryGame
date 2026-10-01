class_name AttackRegistrator extends Node3D

@export var health_manager:HealthManager
@export var hurtbox:Hurtbox

func _ready() -> void:
	hurtbox.received_attack.connect(on_receive_attack)

func on_receive_attack(data:AttackData):
	health_manager.apply_damage(data.damage)
