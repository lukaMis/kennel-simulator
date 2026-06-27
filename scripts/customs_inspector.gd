extends Node

# --- GAME VARIABLES ---
var synergy_multiplier: float = 1.0
#var current_queue_index: int = 0
# --- DOGS VARIABLES ---
var working_dogs = []
var current_dog: DogResource
# --- PACKAGES VARIABLES ---
var packages_to_check = []
var current_package: CargoPackage

@onready var label_payout: Label = %LabelPayout
@onready var label_multiplier: Label = %LabelMultiplier
@onready var label_remaining: Label = %LabelRemaining
@onready var label_dog_name: Label = %LabelDogName
@onready var label_dog_reaction: Label = %LabelDogReaction
@onready var label_package_type: Label = %LabelPackageType
@onready var label_package_sprite: Label = %LabelPackageSprite
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

	CustomsInspectionManager.initialize_shift_session()

	# 3. Pull the data cleanly to populate your UI
	if CustomsInspectionManager.active_shift_roster.is_empty():
		#working_dogs = GlobalState.master_dog_roster.duplicate()
		CustomsInspectionManager.set_shift_team(GlobalState.master_dog_roster)
	#var working_dogs = CustomsInspectionManager.active_shift_roster
	packages_to_check = CustomsInspectionManager.active_queue

	# Just store the team in the manager locker for transit

	# Explicitly connect each button to its own function
	button_pass.pressed.connect(_on_pass_pressed)
	button_doubt.pressed.connect(_on_doubt_pressed)

	button_next.pressed.connect(_load_next_package)
	#button_next.hide()

	#_inspection_buttons_state_update(true)
	_set_inspection_buttons_enabled(false)

	print("Inspector Scene: Loaded successfully with ", working_dogs.size(), " dogs.")
	print("Inspector Scene: Loaded successfully with ", packages_to_check.size(), " packages.")
	CustomsInspectionManager.start_shift()


func _clear_local_data() -> void:
	synergy_multiplier = 1
	working_dogs.clear()
	current_dog = null
	packages_to_check.clear()
	current_package = null


func _on_shift_started() -> void:
	# Assume index 0 for prototype, logic can be expanded for multiple dogs
	current_dog = CustomsInspectionManager.active_shift_roster[0]
	current_dog.reset_session()
	# NEW: Initialize UI elements immediately
	label_multiplier.text = "Multiplier: 1.0x"

	label_dog_name.text = current_dog.name
	label_payout.text = "Payout: $" + str(CustomsInspectionManager.shift_current_payout)

	#label_remaining.text = str(CustomsInspectionManager.active_queue.size() - current_queue_index)
	# NEW: Just use the size of the array directly
	label_remaining.text = "Packages to inspect:" + " " + str(CustomsInspectionManager.active_queue.size())
	#_load_next_package()


func _on_shift_ended() -> void:
	# clear local data
	_clear_local_data()
	pass


func _load_next_package() -> void:
	# NEW: Check if the queue is empty
	if CustomsInspectionManager.active_queue.is_empty():
		print("Shift Complete")
		return

	# NEW: Always grab the first package in line
	current_package = CustomsInspectionManager.active_queue[0]

	# Remove the package from the queue via the Manager
	CustomsInspectionManager.remove_inspected_package()

	# Update UI with current package info
	label_package_type.text = "Type: " + current_package.contraband_type
	label_package_sprite.text = "ID: " + str(current_package.visual_sprite_id)
	#label_remaining.text = str(CustomsInspectionManager.active_queue.size())
	label_remaining.text = "Packages to inspect:" + " " + str(CustomsInspectionManager.active_queue.size())

	label_feedback.text = ""

	#label_remaining.text = str(CustomsInspectionManager.active_queue.size() - current_queue_index)

	# 1. Display the "Tell" (System 6: Tell phase)
	var reaction = current_dog.tell_reactions[current_dog.current_confidence_level][current_package.is_contraband]
	label_dog_reaction.text = reaction

	button_next.hide()
	#button_pass.disabled = false
	#button_doubt.disabled = false
	#_inspection_buttons_state_update(false)
	_set_inspection_buttons_enabled(true)


#
#func _on_action_pressed(is_doubting: bool) -> void:
#button_pass.disabled = true
#button_doubt.disabled = true
#
#var is_correct = (is_doubting == current_package.is_contraband)
#
## 2. Update Stats
#current_dog.record_inspection_result(is_correct)
#
## Update confidence
#if is_correct:
#synergy_multiplier += 0.1 # Example increment
#label_multiplier.text = "Multiplier: " + str(snappedf(synergy_multiplier, 0.1)) + "x"
#current_dog.increase_confidence()
## Determine outcome key
#var outcome_key = "correct_seize" if is_doubting else "correct_pass"
#label_feedback.text = current_dog.outcome_reactions[outcome_key]
#else:
#synergy_multiplier = 1.0 # Reset on failure
#label_multiplier.text = "Multiplier: 1.0x"
#current_dog.decrease_confidence()
## Determine outcome key
#var outcome_key = "wrong_seize" if is_doubting else "wrong_pass"
#label_feedback.text = current_dog.outcome_reactions[outcome_key]
#
#button_next.show()
#current_queue_index += 1
#
#
# --- BUTTON SIGNALS ---
func _on_pass_pressed() -> void:
	# Pass means we are NOT doubting (is_doubting = false)
	_process_inspection_action(false)


func _on_doubt_pressed() -> void:
	# Doubt means we ARE doubting (is_doubting = true)
	_process_inspection_action(true)


# --- HELPER LOGIC ---
func _process_inspection_action(is_doubting: bool) -> void:
	# Disable buttons immediately
	#button_pass.disabled = true
	#button_doubt.disabled = true
	#_inspection_buttons_state_update(true)
	_set_inspection_buttons_enabled(false)

	var is_correct = (is_doubting == current_package.is_contraband)

	# Update Stats
	current_dog.record_inspection_result(is_correct)

	# Update confidence and UI
	if is_correct:
		synergy_multiplier += 0.1
		label_multiplier.text = "Multiplier: " + str(snappedf(synergy_multiplier, 0.1)) + "x"
		current_dog.increase_confidence()
		var outcome_key = "correct_seize" if is_doubting else "correct_pass"
		label_feedback.text = current_dog.outcome_reactions[outcome_key]
	else:
		synergy_multiplier = 1.0
		label_multiplier.text = "Multiplier: 1.0x"
		current_dog.decrease_confidence()
		var outcome_key = "wrong_seize" if is_doubting else "wrong_pass"
		label_feedback.text = current_dog.outcome_reactions[outcome_key]

	## NEW: Remove the package from the queue via the Manager
	#CustomsInspectionManager.remove_inspected_package()
	button_next.show()

	#current_queue_index += 1


func _set_inspection_buttons_enabled(is_enabled: bool):
	button_pass.disabled = not is_enabled
	button_doubt.disabled = not is_enabled

	button_pass.visible = is_enabled
	button_doubt.visible = is_enabled


func _inspection_buttons_state_update(disable_buttons: bool) -> void:
	if disable_buttons:
		button_pass.disabled = true
		button_doubt.disabled = true
		button_pass.hide()
		button_doubt.hide()
	else:
		button_pass.disabled = false
		button_doubt.disabled = false
		button_pass.show()
		button_doubt.show()
