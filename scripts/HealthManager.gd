extends Node3D
class_name HealthManager

@export var health:float
@export var max_health:float
@export var restore_health_on_ready:bool = true

signal applied_damage (damage:float, remaining_health:float)
signal applied_attack (damage:float, attacker:Node3D, remaining_health:float)
signal applied_healing (healing:float, remaining_health:float)
signal depleted_health
signal maxed_health

func _ready() -> void:
	apply_healing(0)
	if restore_health_on_ready:
		restore_health()

func restore_health():
	health = max_health

func heal_to_max():
	var delta:float = max_health-health
	apply_healing(delta)

func apply_damage(damage:float):
	health -= damage
	applied_damage.emit(damage, health)
	if health <= 0:
		health = 0
		depleted_health.emit()

func set_health(health_val:float):
	health = health_val
	if health <= 0:
		health = 0
		depleted_health.emit()

func apply_healing(healing:float):
	health += healing
	applied_healing.emit(healing, health)
	if health >= max_health:
		health = max_health
		maxed_health.emit()
