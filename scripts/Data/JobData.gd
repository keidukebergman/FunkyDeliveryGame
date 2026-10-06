class_name JobData extends Resource

@export var title: String
@export_multiline var long_description: String
@export var short_description: String

@export_group("Locations")
@export var pickup_location: Array
@export var dropoff_location: Array

@export_group("Timing")
@export var has_time_limit: bool = false
@export var starts_timer_on_pickup = true
@export_range(30.0, 1800.0, 1.0, "suffix:s") var time_limit: float = 120.0

@export_group("Reward")
@export var base_reward: int = 100

@export_group("Misc")
@export var cargo: PackedScene
@export var tags: Array[StringName] = [] 
@export var can_be_removed:bool = true
