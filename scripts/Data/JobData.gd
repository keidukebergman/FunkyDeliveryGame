class_name JobData extends Resource

@export var title: String
@export_multiline var long_description: String
@export var short_description: String

@export_group("Objectives")
@export var custom_job_outline: bool = false
@export var job_outline = null
@export var pickup_location = Location
@export var delivery_location = Location

@export_group("Reward")
@export var base_reward: int = 100

@export_group("Tags") 
@export var persistent:bool = false
@export var one_time_completable:bool = false
