class_name ProjectileAttackHandler extends Node3D

@export var root:Node3D
@export var hitbox:Hitbox
@export var damage:float = 10
@export var can_hit_entity_once:bool = true
@export var can_hit_hurtbox:bool = true

signal applied_attack()
signal hit_obstacle()

func _ready() -> void:
	hitbox.hit_entity.connect(on_hit_entity)

func on_hit_entity(entity):
	if entity is Hurtbox:
		on_projectile_hit_hurtbox(entity as Hurtbox)
	else:
		on_hit_obstacle()

func on_hit_obstacle():
	hit_obstacle.emit()

func on_projectile_hit_hurtbox (hurtbox:Hurtbox):
	var target = hurtbox
	var atk_data = AttackData.new(
		damage,
		root,
		target,
		hitbox,
		target,
		{}
	)
	target.apply_attack(atk_data)
	applied_attack.emit()
