class_name FlakClusterShell extends Bullet

@export var cluster_amount: int = 90
@export var cluster_bomblet: PackedScene
@export var cluster_bomblet_life_offset:float = 0.2
@export var cluster_bomblet_speed_offset:float = 10

func on_lifetime_timeout():
	for n in cluster_amount:
		var bomb_instance = cluster_bomblet.instantiate() as Bullet
		get_tree().get_root().add_child(bomb_instance)
		bomb_instance.global_position = global_position
		bomb_instance.global_rotation = Vector3(randf_range(-180, 180),randf_range(-180, 180),randf_range(-180, 180))
		bomb_instance.lifetime += randf_range(-cluster_bomblet_life_offset, cluster_bomblet_life_offset)
		bomb_instance.projectile_speed += randf_range(-cluster_bomblet_speed_offset, cluster_bomblet_speed_offset)
	super.on_lifetime_timeout()
