extends Node

# --- GAME VARIABLES ---
var synergy_multiplier: float = 1.0
# --- DOGS VARIABLES ---
var current_dog: DogResource
# --- PACKAGES VARIABLES ---
var current_package: CargoPackage

@onready var label_payout: Label = %LabelPayout
@onready var label_multiplier: Label = %LabelMultiplier
@onready var label_remaining: Label = %LabelRemaining
@onready var label_dog_name: Label = %LabelDogName
@onready var label_dog_reaction: Label = %LabelDogReaction
@onready var label_package_type: Label = %LabelPackageType
@onready var label_package_owner: Label = %LabelPackageOwner
@onready var label_feedback: Label = %LabelFeedback
@onready var button_pass: Button = %ButtonPass
@onready var button_doubt: Button = %ButtonInspect
@onready var button_next: Button = %ButtonNext


func _ready() -> void:
	# clear local data
	_clear_local_data()

	# Connect signals
	CustomsInspectionManager.shift_started.connect(_on_shift_started)
	CustomsInspectionManager.shift_ended.connect(_on_shift_ended)

	# Tell CustomsInspectionManager to generate packages
	CustomsInspectionManager.initialize_shift_session()

	# 3. Pull the data cleanly to populate your UI
	# TODO, remove this check, it is Fallback check for localized scene running/debugging
	if CustomsInspectionManager.active_shift_dog == null:
		if not GlobalState.master_dog_roster.is_empty():
			CustomsInspectionManager.set_shift_dog(GlobalState.master_dog_roster[0])

	# Explicitly connect each button to its own function
	button_pass.pressed.connect(_on_pass_pressed)
	button_doubt.pressed.connect(_on_doubt_pressed)

	button_next.pressed.connect(_load_next_package)

	_set_inspection_buttons_enabled(false)
	# Read directly from the manager for your debug prints
	print("Inspector Scene: Loaded successfully with ", CustomsInspectionManager.active_shift_dog, " dog.")
	print("Inspector Scene: Loaded successfully with ", CustomsInspectionManager.active_queue.size(), " packages.")

	CustomsInspectionManager.start_shift()


func _clear_local_data() -> void:
	synergy_multiplier = 1

	current_dog = null

	current_package = null


func _on_shift_started() -> void:
	# REFACTORED: No arrays or indices needed! Grab the variable object directly.
	current_dog = CustomsInspectionManager.active_shift_dog
	current_dog.reset_session()

	# NEW: Initialize UI elements immediately
	label_multiplier.text = "Multiplier: 1.0x"

	label_dog_name.text = current_dog.name
	label_payout.text = "Payout: $" + str(CustomsInspectionManager.shift_current_payout)

	label_remaining.text = "Remaining packages to inspect:" + " " + str(CustomsInspectionManager.active_queue.size())


func _on_shift_ended() -> void:
	_clear_local_data()
	pass


func _load_next_package() -> void:
	# Hide next package button
	button_next.hide()

	# Check if the queue is empty
	if CustomsInspectionManager.active_queue.is_empty():
		print("Shift Complete")
		return

	# Always grab the first package in line from remaining packages
	current_package = CustomsInspectionManager.active_queue[0]

	# Update UI with current package info
	label_package_type.text = "Package: " + current_package.package_type
	label_package_owner.text = "Owner: " + current_package.package_owner

	# Update UI with current package queue info

	label_remaining.text = "Remaining packages to inspect:" + " " + str(GameConstants.CUSTOMS_QUOTA) + "/" + str(CustomsInspectionManager.active_queue.size())

	label_feedback.text = ""

	# 1. Display the "Tell" (System 6: Tell phase)
	var reaction = current_dog.tell_reactions[current_dog.current_confidence_level][current_package.is_contraband]
	label_dog_reaction.text = reaction

	# Remove the package from the shift queue via the Manager
	CustomsInspectionManager.remove_inspected_package()

	# Update UI with current package queue info
	label_remaining.text = "Remaining packages to inspect: %s\\%s" % [str(CustomsInspectionManager.active_queue.size()), str(GameConstants.CUSTOMS_QUOTA)]

	# Enable inspection buttons
	_set_inspection_buttons_enabled(true)


# --- BUTTON SIGNALS ---
func _on_pass_pressed() -> void:
	# Pass means we are NOT doubting (is_doubting = false)
	_process_inspection_action(false)


func _on_doubt_pressed() -> void:
	# Doubt means we ARE doubting (is_doubting = true)
	_process_inspection_action(true)


# --- END OF BUTTON SIGNALS ---
# --- HELPER LOGIC ---
func _process_inspection_action(is_doubting: bool) -> void:
	# Disable inspection buttons immediately
	_set_inspection_buttons_enabled(false)

	var is_correct = (is_doubting == current_package.is_contraband)

	# Update Stats
	current_dog.record_inspection_result(is_correct)

	# Update confidence and UI
	var outcome_key: String = ""
	if is_correct:
		synergy_multiplier += 0.1
		label_multiplier.text = "Multiplier: " + str(snappedf(synergy_multiplier, 0.1)) + "x"
		current_dog.increase_confidence()
		outcome_key = "correct_seize" if is_doubting else "correct_pass"
	else:
		synergy_multiplier = 1.0
		label_multiplier.text = "Multiplier: 1.0x"
		current_dog.decrease_confidence()
		outcome_key = "wrong_seize" if is_doubting else "wrong_pass"

	label_dog_reaction.text = current_dog.outcome_reactions[outcome_key]
	label_feedback.text = current_package.outcome_reactions[outcome_key]
	button_next.show()


func _set_inspection_buttons_enabled(is_enabled: bool):
	button_pass.disabled = not is_enabled
	button_doubt.disabled = not is_enabled

	button_pass.visible = is_enabled
	button_doubt.visible = is_enabled
