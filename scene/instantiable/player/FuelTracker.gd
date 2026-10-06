class_name FuelTracker extends Node3D

@export var max_fuel:float
var current_fuel:float
var current_fuel_drain_rate:float
@export var is_draining_fuel:bool = true
@export var fuel_drain_rate_low:float
@export var fuel_drain_rate:float
@export var fuel_drain_rate_high:float

enum FuelDrainRate {
	NONE,
	LOW,
	MEDIUM,
	HIGH
}
signal fuel_depleted

func ready():
	current_fuel = max_fuel


func _process(delta):
	if is_draining_fuel:
		current_fuel -= current_fuel_drain_rate * delta
		if(current_fuel < 0):
			is_draining_fuel = false
			fuel_depleted.emit()

func set_fuel_depletion_rate(rate:FuelDrainRate):
	match rate:
		FuelDrainRate.NONE:
			current_fuel_drain_rate = 0
		FuelDrainRate.LOW:
			current_fuel_drain_rate = fuel_drain_rate_low
		FuelDrainRate.MEDIUM:
			current_fuel_drain_rate = fuel_drain_rate
		FuelDrainRate.HIGH:
			current_fuel_drain_rate = fuel_drain_rate_high
