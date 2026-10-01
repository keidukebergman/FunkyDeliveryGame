class_name MissileTarget extends Node3D
signal missile_detected(missile:Missile)
signal missile_lost(missile:Missile)

var tracking_missiles: Array[Missile]

func get_targeted(missile:Missile):
	tracking_missiles.append(missile)
	print("We are targeted by ", tracking_missiles.size(), " missiles")
	missile_detected.emit(missile)

func remove_target_lock(missile:Missile):
	tracking_missiles.erase(missile)
	missile_lost.emit(missile)
