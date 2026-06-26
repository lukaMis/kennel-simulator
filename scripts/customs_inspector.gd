extends Node

# Add these variables at the top
var synergy_multiplier: float = 1.0
var current_dog: DogResource
var current_package: CargoPackage
var current_queue_index: int = 0

@onready var label_multiplier = %LabelMultiplier # Make sure to add this node to your scene
@onready var label_package_type = %LabelPackageType
@onready var label_package_sprite = %LabelPackageSprite
@onready var label_dog_reaction = %LabelDogReaction
@onready var label_feedback = %LabelFeedback
@onready var button_pass = %ButtonPass
@onready var button_doubt = %ButtonInspect # Renaming logic for clarity
@onready var button_next = %ButtonNext
@onready var label_dog_name = %LabelDogName
@onready var label_payout = %LabelPayout


func _ready() -> void:
	# Connect signals
	CustomsInspectionManager.shift_started.connect(_on_shift_started)
	CustomsInspectionManager.shift_ended.connect(_on_shift_ended)
	CustomsInspectionManager.initialize_shift_session()

	# 3. Pull the data cleanly to populate your UI
	var working_dogs = CustomsInspectionManager.active_shift_roster
	var packages_to_check = CustomsInspectionManager.active_queue

	# Setup input
	button_pass.pressed.connect(_on_action_pressed.bind(false)) # False = Pass
	button_doubt.pressed.connect(_on_action_pressed.bind(true)) # True = Doubt
	button_next.pressed.connect(_load_next_package)
	button_next.hide()

	print("Inspector Scene: Loaded successfully with ", working_dogs.size(), " dogs.")
	print("Inspector Scene: Loaded successfully with ", packages_to_check.size(), " packages.")
	CustomsInspectionManager.start_shift()


func _on_shift_started() -> void:
	# Assume index 0 for prototype, logic can be expanded for multiple dogs
	current_dog = CustomsInspectionManager.active_shift_roster[0]
	current_dog.reset_session()
	# NEW: Initialize UI elements immediately
	label_multiplier.text = "Multiplier: 1.0x"

	label_dog_name.text = current_dog.name
	label_payout.text = "Payout: $" + str(CustomsInspectionManager.shift_current_payout)
	_load_next_package()


func _on_shift_ended() -> void:
	pass


func _load_next_package() -> void:
	if current_queue_index >= CustomsInspectionManager.active_queue.size():
		print("Shift Complete")
		return

	current_package = CustomsInspectionManager.active_queue[current_queue_index]

	# Update UI with current package info
	label_package_type.text = "Type: " + current_package.contraband_type
	label_package_sprite.text = "ID: " + str(current_package.visual_sprite_id)

	button_next.hide()
	label_feedback.text = ""

	# 1. Display the "Tell" (System 6: Tell phase)
	var reaction = current_dog.tell_reactions[current_dog.current_confidence_level][current_package.is_contraband]
	label_dog_reaction.text = reaction

	button_pass.disabled = false
	button_doubt.disabled = false


func _on_action_pressed(is_doubting: bool) -> void:
	button_pass.disabled = true
	button_doubt.disabled = true

	var is_correct = (is_doubting == current_package.is_contraband)

	# 2. Update Stats
	current_dog.record_inspection_result(is_correct)

	# Update confidence
	if is_correct:
		synergy_multiplier += 0.1 # Example increment
		label_multiplier.text = "Multiplier: " + str(snappedf(synergy_multiplier, 0.1)) + "x"
		current_dog.increase_confidence()
		# Determine outcome key
		var outcome_key = "correct_seize" if is_doubting else "correct_pass"
		label_feedback.text = current_dog.outcome_reactions[outcome_key]
	else:
		synergy_multiplier = 1.0 # Reset on failure
		label_multiplier.text = "Multiplier: 1.0x"
		current_dog.decrease_confidence()
		# Determine outcome key
		var outcome_key = "wrong_seize" if is_doubting else "wrong_pass"
		label_feedback.text = current_dog.outcome_reactions[outcome_key]

	button_next.show()
	current_queue_index += 1
