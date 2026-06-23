extends ColorRect

const MAX_TEAM_SIZE: int = 2

var selected_team: Array[DogResource] = []

# Adjust this path based on where you store your player's dogs in the kennel scene
# For this example, assuming there is a DogManager autoload or node
# var all_owned_dogs: Array[DogResource] = DogManager.get_all_dogs()
@onready var roster_list: VBoxContainer = $ModalPanel/MarginContainer/VBoxContainer/ContentSplit/LeftColumn/ScrollContainer/RosterList
@onready var team_list: VBoxContainer = $ModalPanel/MarginContainer/VBoxContainer/ContentSplit/RightColumn/TeamList
@onready var button_start: Button = $ModalPanel/MarginContainer/VBoxContainer/ButtonRow/ButtonStart
@onready var button_cancel: Button = $ModalPanel/MarginContainer/VBoxContainer/ButtonRow/ButtonCancel


func _ready() -> void:
	# Hide the modal by default when the kennel loads
	hide()

	button_cancel.pressed.connect(_on_cancel_pressed)
	button_start.pressed.connect(_on_start_pressed)


# Call this from your Main scene when the player clicks the "Work" button
#func open_modal(dogs: Array[DogResource]) -> void:
func open_modal() -> void:
	show()
	selected_team.clear()
	#_populate_roster(dogs)
	_populate_roster(GlobalState.master_dog_roster)
	_update_ui()


func _populate_roster(dogs: Array[DogResource]) -> void:
	print("DEBUG: _populate_roster running. Creating Buttons.") # <--- ADD THIS
	# Debug: Print how many dogs are in the array
	print("Populating roster with ", dogs.size(), " dogs.")
	print("I am adding buttons to: ", roster_list.get_path())
	#return
	# Clear old UI children
	for child in roster_list.get_children():
		child.queue_free()

	for dog in dogs:
		var btn = Button.new()
		#btn.text = "%s (Energy: %d)" % [dog.dog_name, dog.energy]
		btn.text = "%s (Energy: %d)" % [dog.name, dog.energy]

		# Stat Validation: Lock out exhausted or sleeping dogs
		if dog.energy < 20.0 or dog.is_sleeping:
			btn.disabled = true
			btn.text += " - UNAVAILABLE"
		else:
			# Bind the specific dog resource to the button press
			btn.pressed.connect(_on_roster_dog_selected.bind(dog))

		roster_list.add_child(btn)


func _on_roster_dog_selected(dog: DogResource) -> void:
	if selected_team.size() < MAX_TEAM_SIZE and not selected_team.has(dog):
		selected_team.append(dog)
		_update_ui()


func _update_ui() -> void:
	# Update the right column (Selected Team)
	for child in team_list.get_children():
		child.queue_free()

	for dog in selected_team:
		var lbl = Label.new()
		lbl.text = "- %s" % dog.dog_name
		team_list.add_child(lbl)

	# Enable the Start button only if at least 1 dog is selected
	button_start.disabled = selected_team.is_empty()


func _on_cancel_pressed() -> void:
	hide()


func _on_start_pressed() -> void:
	# 1. Clear old data from the bridge
	GlobalState.clear_shift_data()

	# 2. Push the selected team to the global courier
	GlobalState.active_shift_roster = selected_team.duplicate()

	# 3. Call the generation logic (Phase 3 - to be implemented)
	_generate_cargo_queue()

	# 4. Halt time and swap scenes (Phase 4)
	# 4. Halt the TimeEngine clock by setting its internal running boolean flag to false
	GlobalState.game_is_running = false
	TimeEngine.process_mode = Node.PROCESS_MODE_DISABLED
	#get_tree().change_scene_to_file("res://scenes/customs_inspector.tscn")


# Placeholder for Phase 3
func _generate_cargo_queue() -> void:
	print("Generating cargo queue based on GameConstants...")
	# Clean slate safety check
	GlobalState.shift_cargo_queue.clear()

	# Set the quota and base payout for the contract from our constants
	GlobalState.shift_quota = GameConstants.CUSTOMS_QUOTA
	GlobalState.shift_current_payout = GameConstants.CUSTOMS_BASE_PAYOUT

	# Loop through our required quota count to build individual packages
	for i in range(GameConstants.CUSTOMS_QUOTA):
		var package: Dictionary = {
			"is_contraband": false,
			"contraband_type": "Safe",
			"visual_sprite_id": randi_range(1, 4), # Picks a random box layout
		}
		# Roll against our 30% contraband constant
		if randf() < GameConstants.CUSTOMS_CONTRABAND_CHANCE:
			package["is_contraband"] = true

			# Roll a 50/50 split on whether the contraband is Organic or Mineral
			if randf() < 0.5:
				package["contraband_type"] = "Organic"
			else:
				package["contraband_type"] = "Mineral"

		# Push our finished data packet into the global array bridge
		GlobalState.shift_cargo_queue.append(package)

	print("Successfully generated cargo queue. Total items: ", GlobalState.shift_cargo_queue.size())
	# Math will go here
