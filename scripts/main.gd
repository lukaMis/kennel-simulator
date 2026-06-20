extends Node

@onready var dog_manager = $DogManager
@onready var cash_ui = $CashUI
@onready var info_bar = $InfoBar
@onready var day_summary_ui: Control = $DaySummaryUI


func _ready() -> void:
	# Tune into the time engine's daily broadcast
	TimeEngine.day_passed.connect(_on_day_passed)


func _on_day_passed(current_day: int) -> void:
	var active_dog_count: int = dog_manager.array_of_dogs.size()
	# Trigger the phase shift
	day_summary_ui.trigger_summary(current_day, active_dog_count)
