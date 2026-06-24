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
	_refresh_ui()
	show()


func _refresh_ui() -> void:
	# 2. Rebuild Roster (Left Side)
	_rebuild_roster()

	# 3. Rebuild Team (Right Side)
	_rebuild_shift_team()

	# Update start button state
	button_start.disabled = selected_team.is_empty()


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


func _on_roster_dog_selected(dog: DogResource) -> void:
	if selected_team.size() < MAX_TEAM_SIZE:
		selected_team.append(dog)
		_refresh_ui()


func _on_team_dog_clicked(dog: DogResource) -> void:
	selected_team.erase(dog)
	_refresh_ui()


func _rebuild_roster() -> void:
	# clear current roster
	for child in roster_list.get_children():
		child.queue_free()

	# 2. Rebuild Roster (Left Side)
	for dog in GlobalState.master_dog_roster:
		var btn = Button.new()
		btn.text = "%s (Energy: %d)" % [dog.name, dog.energy]

		# Disable if exhausted, sleeping, OR already selected
		var is_in_team = selected_team.has(dog)
		if dog.energy < 20.0 or dog.is_sleeping or is_in_team:
			btn.disabled = true
			if is_in_team:
				btn.text += " (Selected)"
		else:
			btn.pressed.connect(_on_roster_dog_selected.bind(dog))

		roster_list.add_child(btn)


func _rebuild_shift_team():
	# clear current team
	for child in team_list.get_children():
		child.queue_free()

	# 3. Rebuild Team (Right Side)
	for dog in selected_team:
		var btn = Button.new()
		btn.text = "Remove %s" % dog.name
		# When clicked, remove this specific dog
		btn.pressed.connect(_on_team_dog_clicked.bind(dog))
		team_list.add_child(btn)
