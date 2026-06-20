class_name DogResource
extends Resource

@export var name: String = "Doggy name"
@export var hunger: int = 100 # 0 is starving, 100 is full
@export var energy: int = 100 # 0 is exhausted, 100 is hyper
@export var is_sleeping: bool = false
@export var hunger_drain_rate: int = 5
@export var energy_drain_rate: int = 5


func tick_stats():
	if is_sleeping:
		energy = min(energy + GameConstants.SLEEP_ENERGY_GAIN, 100)
		hunger = max(hunger - (hunger_drain_rate * 1.5), 0)
	else:
		energy = max(energy - energy_drain_rate, 0)
		hunger = max(hunger - hunger_drain_rate, 0)


func wake_and_rest_dog() -> void:
	is_sleeping = false
	energy = 100
	pass
