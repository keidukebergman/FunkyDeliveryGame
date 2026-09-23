class_name AttackData

var damage : float = 0
var attacker : Node3D
var receiver : Node3D
var attacking_hitbox : Hitbox
var receiving_hurtbox : Hurtbox
var effects : Dictionary

func _init(damage, attacker, receiver, attacking_hitbox, receiving_hurtbox, effects):
	self.damage = damage
	self.attacker = attacker
	self.receiver = receiver
	self.attacking_hitbox = attacking_hitbox
	self.receiving_hurtbox = receiving_hurtbox
	self.effects = effects
