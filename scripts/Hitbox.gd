extends Area3D
class_name Hitbox

var is_active: bool = false
var hits: Dictionary = {}
signal hit_entity(node)
@export var start_detecting_on_enable:bool = true
@export var ignore_colliders:Array[Node3D]

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	self.area_entered.connect(_on_area_entered)
	if start_detecting_on_enable:
		start_detecting_hits()

func start_detecting_hits() -> void:
	is_active = true
	hits.clear()

func stop_detecting_hits() -> void:
	is_active = false

func _process(_delta: float) -> void:
	if is_active:
		detect_hit()

func detect_hit() -> void:
	var overlapping_bodies = get_overlapping_bodies()
	var overlapping_areas = get_overlapping_areas()
	for body in overlapping_bodies:
		detect_collision(body)
	for area in overlapping_areas:
		detect_collision(area)

func _on_body_entered(body: Node3D) -> void:
	if is_active:
		detect_collision(body)

func _on_area_entered(area: Area3D) -> void:
	if is_active:
		detect_collision(area)

func detect_collision(node: Node3D) -> void:
	if node not in hits && node not in ignore_colliders:
		hits[node] = true
		hit_entity.emit(node)
