extends Node

@onready var dog_manager = $DogManager
@onready var cash_ui = $UILayer/CashUI
@onready var info_bar = $UILayer/InfoBar
@onready var day_summary_ui: Control = $UILayer/DaySummaryUI
@onready var staging_modal: ColorRect = $UILayer/CustomsStagingModal
@onready var button_work: Button = $UILayer/WorkButton


func _ready() -> void:
	# Tune into the time engine's daily broadcast
	TimeEngine.day_passed.connect(_on_day_passed)
	TimeEngine.game_time_update.connect(_on_game_time_update)

	# 1. Connect the new work button!
	button_work.pressed.connect(_on_button_work_pressed)


func _on_day_passed(current_day: int) -> void:
	var active_dog_count: int = GlobalState.master_dog_roster.size()
	# Trigger the phase shift
	day_summary_ui.trigger_summary(current_day, active_dog_count)
	button_work.hide()


func _on_button_work_pressed() -> void:
	staging_modal.open_modal()


func _on_game_time_update(time_data: Dictionary) -> void:
	_update_work_button_visibility(time_data.hour)
	#print(time_data)


func _update_work_button_visibility(current_game_hour: int) -> void:
	button_work.visible = (current_game_hour < 15)
