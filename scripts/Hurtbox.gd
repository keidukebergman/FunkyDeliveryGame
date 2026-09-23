extends Area3D
class_name Hurtbox

var is_active: bool = false
signal received_attack(data:AttackData)

func _ready() -> void:
	is_active = true
	pass

func verify_hit() -> bool:
	return true

func apply_attack(attack_data:AttackData) -> void:
	if !is_active:
		return
	received_attack.emit(attack_data)
