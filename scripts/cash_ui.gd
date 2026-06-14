extends Control

@onready var label_cash: Label = $LabelCash


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Listen to the global cloud for any bank balance updates
	GlobalState.cash_changed.connect(update_cash_ui)
	# 2. Set the initial text right away when the game boots up
	update_cash_ui(GlobalState.cash)


# This function matches the signal parameter layout!
func update_cash_ui(new_amount: int) -> void:
	label_cash.text = "Money available: " + str(new_amount)
