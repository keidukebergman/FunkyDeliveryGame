class_name Explosion extends Node3D

@export var life_time = 0.3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(life_time).timeout
	queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
