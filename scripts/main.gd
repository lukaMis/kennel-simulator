extends Node

@onready var dog_manager = $DogManager
@onready var cash_ui = $UILayer/CashUI
@onready var info_bar = $UILayer/InfoBar
@onready var day_summary_ui: Control = $UILayer/DaySummaryUI
@onready var staging_modal: ColorRect = $UILayer/CustomsStagingModal
@onready var work_button: Button = $UILayer/WorkButton


func _ready() -> void:
	# Tune into the time engine's daily broadcast
	TimeEngine.day_passed.connect(_on_day_passed)

	# 1. Connect the new work button!
	work_button.pressed.connect(_on_work_button_pressed)


func _on_day_passed(current_day: int) -> void:
	var active_dog_count: int = GlobalState.master_dog_roster.size()
	# Trigger the phase shift
	day_summary_ui.trigger_summary(current_day, active_dog_count)


func _on_work_button_pressed() -> void:
	staging_modal.open_modal()
