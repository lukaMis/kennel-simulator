extends ColorRect

const MAX_TEAM_SIZE: int = 2

var selected_team: Array[DogResource] = []

@onready var roster_list: VBoxContainer = %RosterList
@onready var team_list: VBoxContainer = %TeamList
@onready var button_start: Button = %ButtonStart
@onready var button_cancel: Button = %ButtonCancel


func _ready() -> void:
	# Hide the modal by default when the kennel loads
	hide()

	button_cancel.pressed.connect(_on_cancel_pressed)
	button_start.pressed.connect(_on_start_pressed)


# Call this from your Main scene when the player clicks the "Work" button
func open_modal() -> void:
	# 1. Freeze the game state immediately
	GlobalState.set_game_running(false)

	selected_team.clear()

	_populate_roster(GlobalState.master_dog_roster)
	_update_ui()
	show()


func _on_cancel_pressed() -> void:
	# 2. Unfreeze the game if they back out!
	GlobalState.set_game_running(true)
	hide()


func _on_start_pressed() -> void:
	# 1. Hand the selected team over to the manager and let it handle the rest
	CustomsInspectionManager.start_shift(selected_team)

	# 2. Hide the modal
	hide()

	# 3. Swap to the minigame scene
	get_tree().change_scene_to_file("res://scenes/customs_inspector.tscn")


func _populate_roster(dogs: Array[DogResource]) -> void:
	for child in roster_list.get_children():
		child.queue_free()

	for dog in dogs:
		var btn = Button.new()
		btn.text = "%s (Energy: %d)" % [dog.name, dog.energy]

		# Stat Validation: Lock out exhausted or sleeping dogs
		if dog.energy < 20.0 or dog.is_sleeping:
			btn.disabled = true
			btn.text += " - UNAVAILABLE"
		else:
			# Bind the specific dog resource to the button press
			btn.pressed.connect(_on_roster_dog_selected.bind(dog))

		roster_list.add_child(btn)


func _update_ui() -> void:
	# Update the right column (Selected Team)
	for child in team_list.get_children():
		child.queue_free()

	for dog in selected_team:
		var lbl = Label.new()
		lbl.text = "- %s" % dog.name
		team_list.add_child(lbl)

	# Enable the Start button only if at least 1 dog is selected
	button_start.disabled = selected_team.is_empty()


func _on_roster_dog_selected(dog: DogResource) -> void:
	if selected_team.size() < MAX_TEAM_SIZE and not selected_team.has(dog):
		selected_team.append(dog)
		_update_ui()
