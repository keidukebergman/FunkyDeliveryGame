class_name AttackData extends Resource

var damage : float = 0
var attacker : Node3D
var receiver : Node3D
var attacking_hitbox : Hitbox
var receiving_hurtbox : Hurtbox
var effects : Dictionary

func _init(damage_value, attacker_value, receiver_value, attacking_hitbox_value, receiving_hurtbox_value, effects_value):
	self.damage = damage_value
	self.attacker = attacker_value
	self.receiver = receiver_value
	self.attacking_hitbox = attacking_hitbox_value
	self.receiving_hurtbox = receiving_hurtbox_value
	self.effects = effects_value
