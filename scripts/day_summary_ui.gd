extends Control

# 2. Define our economic math
var pending_cost: int = 0
var base_rent: int = GameConstants.BASE_RENT
var food_cost_per_dog: int = GameConstants.FOOD_COST
var total_food_cost: int = 0

@onready var breakdown_label: RichTextLabel = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BreakdownLabel
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var pay_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PayButton


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
	_update_title_label(_format_title_text(current_day))
	_update_breakdown_label(_format_breakdown_text(dog_count))

	# 4. Show the modal
	show()
	pass


func _format_title_text(current_day: int) -> String:
	var completed_day: int = current_day - 1
	var title_text: String = "End of Day %d\n\n" % completed_day
	return title_text


func _update_title_label(new_title_text: String) -> void:
	title_label.text = new_title_text
	pass


func _format_breakdown_text(dog_count: int) -> String:
	# 3. Format the UI text readout
	var daily_summary_text: String = "Facility Rent: -$%d\n" % base_rent
	daily_summary_text += "Dog Food (%d dogs): -$%d\n" % [dog_count, total_food_cost]
	daily_summary_text += "------------------------\n"
	daily_summary_text += "Total Due: -$%d" % pending_cost
	return daily_summary_text


func _update_breakdown_label(new_daily_summary_text: String) -> void:
	breakdown_label.text = new_daily_summary_text
	pass


func _on_pay_button_pressed() -> void:
	# 1. Attempt to spend money
	var success: bool = GlobalState.try_spend_money(pending_cost)
	if success:
		# 2. Success: Hide UI and resume time
		hide()
		GlobalState.game_info_change("Paid daily upkeep of $" + str(pending_cost))
		TimeEngine.start_morning()
		GlobalState.set_game_running(true)
	else:
		_handle_game_over()


func _handle_game_over() -> void:
	# 3. Failure: Handle bankruptcy
	GlobalState.game_info_change("BANKRUPT! Not enough funds for upkeep.")

	title_label.text = "Game over"
	breakdown_label.text = "BANKRUPT! Not enough funds for upkeep."
	pay_button.text = ""
	pay_button.disabled = true
