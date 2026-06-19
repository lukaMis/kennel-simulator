extends Control

var pending_cost: int = 0
# 2. Define our economic math
var base_rent: int = 20
var food_cost_per_dog: int = 5
var total_food_cost: int = 0

@onready var breakdown_label: Label = $PanelContainer/MarginContainer/VBoxContainer/BreakdownLabel
@onready var pay_button: Button = $PanelContainer/MarginContainer/VBoxContainer/PayButton


func _ready() -> void:
	# Ensure this screen is completely hidden when the game boots
	hide()

	# Connect the button click to our function
	pay_button.pressed.connect(_on_pay_button_pressed)


func trigger_summary(current_day: int, dog_count: int) -> void:
	# 1. Halt the simulation instantly!
	GlobalState.set_game_running(false)

	# 2. Perform math
	total_food_cost = dog_count * food_cost_per_dog
	pending_cost = base_rent + total_food_cost

	# 3. Update UI
	_update_breakdown_label(_format_breakdown_text(current_day, dog_count))

	# 4. Show the modal
	show()
	pass


func _format_breakdown_text(current_day: int, dog_count: int) -> String:
	# 3. Format the UI text readout
	var text: String = "End of Day %d\n\n" % current_day
	text += "Facility Rent: -$%d\n" % base_rent
	text += "Dog Food (%d dogs): -$%d\n" % [dog_count, total_food_cost]
	text += "------------------------\n"
	text += "Total Due: -$%d" % pending_cost
	return text


func _update_breakdown_label(new_text) -> void:
	breakdown_label.text = new_text
	pass


func _on_pay_button_pressed() -> void:
	# 1. Attempt to spend money
	var success: bool = GlobalState.try_spend_money(pending_cost)
	if success:
		# 2. Success: Hide UI and resume time
		hide()
		GlobalState.game_info_change("Paid daily upkeep of $" + str(pending_cost))
		GlobalState.set_game_running(true)
	else:
		# 3. Failure: Handle bankruptcy
		GlobalState.game_info_change("BANKRUPT! Not enough funds for upkeep.")
		pay_button.text = "Game Over"
		pay_button.disabled = true
