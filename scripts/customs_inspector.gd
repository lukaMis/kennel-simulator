extends Node

# --- DOGS & PACKAGES VARIABLES ---
var current_dog: DogResource
var current_package: CargoPackage

# --- GAME UI NODES ---
@onready var label_payout: Label = %LabelPayout
@onready var label_multiplier: Label = %LabelMultiplier
@onready var label_remaining: Label = %LabelRemaining
@onready var label_dog_name: Label = %LabelDogName
@onready var label_dog_reaction: Label = %LabelDogReaction
@onready var label_package_type: Label = %LabelPackageType
@onready var label_package_owner: Label = %LabelPackageOwner
@onready var label_feedback: Label = %LabelFeedback

@onready var button_pass: Button = %ButtonPass
@onready var button_doubt: Button = %ButtonDoubt
@onready var button_next: Button = %ButtonNext
@onready var button_end_shift: Button = %ButtonEndShift

# --- MODAL UI NODES ---
@onready var end_shift_modal: ColorRect = %EndShiftModal
@onready var label_shift_summary: Label = %LabelShiftSummary
@onready var button_return_home: Button = %ButtonReturnHome


func _ready() -> void:
	_clear_local_data()
	end_shift_modal.hide()

	# Connect signals
	CustomsInspectionManager.shift_started.connect(_on_shift_started)
	CustomsInspectionManager.shift_ended.connect(_on_shift_ended)

	# Tell CustomsInspectionManager to generate packages
	CustomsInspectionManager.initialize_shift_session()

	# Fallback check for localized scene running/debugging
	if CustomsInspectionManager.active_shift_dog == null:
		if not GlobalState.master_dog_roster.is_empty():
			CustomsInspectionManager.set_shift_dog(GlobalState.master_dog_roster[0])

	# Connect buttons
	button_pass.pressed.connect(_on_pass_pressed)
	button_doubt.pressed.connect(_on_doubt_pressed)
	button_next.pressed.connect(_load_next_package)
	button_end_shift.pressed.connect(_on_end_shift_pressed)
	button_return_home.pressed.connect(_on_return_home_pressed)

	_set_inspection_buttons_enabled(false)
	_set_button_end_shift_enabled(false)

	# Start shift
	CustomsInspectionManager.start_shift()


func _clear_local_data() -> void:
	current_dog = null
	current_package = null


func _on_shift_started() -> void:
	current_dog = CustomsInspectionManager.active_shift_dog

	# Initialize UI elements by calling the Manager
	label_multiplier.text = "Multiplier: " + str(CustomsInspectionManager.current_synergy_multiplier) + "x"
	label_dog_name.text = current_dog.name
	label_payout.text = "Payout: $" + str(CustomsInspectionManager.shift_current_payout)
	label_remaining.text = "Remaining packages to inspect: " + str(CustomsInspectionManager.active_queue.size())

	# Load the first package to start the game
	#_load_next_package()


func _on_shift_ended() -> void:
	_clear_local_data()


func _load_next_package() -> void:
	button_next.hide()
	label_feedback.text = ""

	# Check if the queue is empty
	if CustomsInspectionManager.active_queue.is_empty():
		_set_button_end_shift_enabled(true)
		print("Shift Complete")
		return

	# Always grab the first package in line to read data
	current_package = CustomsInspectionManager.active_queue[0]

	# Update UI with current package info
	label_package_type.text = "Package: " + current_package.package_type
	label_package_owner.text = "Owner: " + current_package.package_owner
	label_remaining.text = "Remaining packages to inspect: %s/%s" % [str(CustomsInspectionManager.active_queue.size()), str(GameConstants.CUSTOMS_QUOTA)]

	# Display the "Tell" (System 6: Tell phase)
	var reaction = current_dog.tell_reactions[CustomsInspectionManager.current_confidence_level][current_package.is_contraband]
	label_dog_reaction.text = reaction

	_set_inspection_buttons_enabled(true)


# --- BUTTON SIGNALS ---
func _on_pass_pressed() -> void:
	_process_inspection_action(false)


func _on_doubt_pressed() -> void:
	_process_inspection_action(true)


# --- PURE UI LOGIC: DELEGATES MATH TO MANAGER ---
func _process_inspection_action(is_doubting: bool) -> void:
	_set_inspection_buttons_enabled(false)

	# 1. Ask the Manager what happened
	var result: Dictionary = CustomsInspectionManager.process_inspection_choice(is_doubting)

	# Add this debug print:
	print("DEBUG: Inspector received result. Queue size in Manager is now: ", CustomsInspectionManager.active_queue.size())

	# 2. Paint the UI with the answers
	label_multiplier.text = "Multiplier: " + str(snappedf(result.multiplier, 0.1)) + "x"
	label_dog_reaction.text = result.dog_reaction
	label_feedback.text = result.feedback

	# UPDATE THIS: Display the new payout
	label_payout.text = "Payout: $" + str(result.payout)

	# NEW FIX: Tell the label to visually tick down immediately after the choice!
	label_remaining.text = "Remaining packages to inspect: %s/%s" % [str(CustomsInspectionManager.active_queue.size()), str(GameConstants.CUSTOMS_QUOTA)]

	# 3. Check if we are done
	if result.is_queue_empty:
		button_next.hide()
		_set_button_end_shift_enabled(true)
		print("Shift Complete - Queue is 0")
	else:
		button_next.show()


func _set_inspection_buttons_enabled(is_enabled: bool) -> void:
	button_pass.disabled = not is_enabled
	button_doubt.disabled = not is_enabled
	button_pass.visible = is_enabled
	button_doubt.visible = is_enabled


func _set_button_end_shift_enabled(is_enabled: bool) -> void:
	button_end_shift.disabled = not is_enabled
	button_end_shift.visible = is_enabled


# --- MODAL LOGIC ---
func _on_end_shift_pressed() -> void:
	# 1. Log that the shift is officially completed!
	GlobalState.player_stats.total_inspector_games_played += 1

	# 2. Build the text block by reading directly from the player's global stats
	var stats_text = "--- SHIFT COMPLETE ---\n\n"
	stats_text += "Earnings This Shift: $%d\n" % CustomsInspectionManager.shift_current_payout
	stats_text += "Packages Inspected: %d\n" % CustomsInspectionManager.shift_inspections
	stats_text += "Successful Verdicts: %d\n" % CustomsInspectionManager.shift_successes
	stats_text += "Mistakes Made: %d\n" % CustomsInspectionManager.shift_mistakes
	stats_text += "Contraband Seized: %d\n" % CustomsInspectionManager.shift_contraband_seized

	# 3. Apply the text to your modal's label
	label_shift_summary.text = stats_text

	# 4. Show the modal overlay!
	end_shift_modal.show()

	# 1. Tell the Manager to handle the paycheck and clear memory
	CustomsInspectionManager.stop_shift()


func _on_return_home_pressed() -> void:
	# 1. Advance the game clock by 8 hours
	#GlobalState.add_game_time(8)
	GlobalState.advance_game_hours(8)

	# 2. REACTIVATE the game timer/running state so the kennel/main scene behaves correctly
	GlobalState.set_game_running(true)

	# Transition back to your main menu/kennel scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")
