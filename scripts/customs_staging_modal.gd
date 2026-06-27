extends ColorRect

const MAX_TEAM_SIZE: int = 1

var selected_dog: DogResource = null

@onready var roster_list: VBoxContainer = %RosterList
@onready var team_list: VBoxContainer = %TeamList
@onready var button_start: Button = %ButtonStart
@onready var button_cancel: Button = %ButtonCancel


func _ready() -> void:
	# Hide the modal by default when the kennel loads
	hide()

	selected_dog = null

	# Connect start and cancel game buttons
	button_start.pressed.connect(_on_start_pressed)
	button_cancel.pressed.connect(_on_cancel_pressed)


# Call this from your Main scene when the player clicks the "Work" button
func open_modal() -> void:
	# 1. Freeze the game state immediately
	GlobalState.set_game_running(false)

	selected_dog = null
	_refresh_ui()
	show()


func _on_start_pressed() -> void:
	# 1. Hide the modal
	hide()

	# REFACTORED: Push our single choice straight to the manager
	CustomsInspectionManager.set_shift_dog(selected_dog)

	# 3. Swap to the minigame scene
	get_tree().change_scene_to_file("res://scenes/customs_inspector.tscn")


func _on_cancel_pressed() -> void:
	# 1. Hide the modal
	hide()

	# 2. Unfreeze the game if they back out!
	GlobalState.set_game_running(true)


func _refresh_ui() -> void:
	# 1. Rebuild Roster (Left Side)
	_rebuild_roster()

	# 2. Rebuild Selected Dog (Right Side)
	_rebuild_selected_dog()

	# Start button is disabled if no dog is selected
	button_start.disabled = (selected_dog == null)


func _rebuild_roster() -> void:
	# 1 Clear current Roster (Left Side)
	for child in roster_list.get_children():
		child.queue_free()

	# 2 Rebuild Roster (Left Side)
	var btn: Button = null
	for dog in GlobalState.master_dog_roster:
		# if energy is high enough end dog is NOT sleeping and it is NOT selected, add it to the list of available dogs for shift and make a button for it to add it to the work shift.
		var is_selected = (selected_dog == dog)
		if not dog.energy <= 20.0 and not dog.is_sleeping and not is_selected:
			btn = Button.new()
			btn.text = "%s (Energy: %d)" % [dog.name, dog.energy]
			btn.pressed.connect(_on_roster_dog_selected.bind(dog))
			roster_list.add_child(btn)


func _rebuild_roster_orig() -> void:
	# 1 Clear current Roster (Left Side)
	for child in roster_list.get_children():
		child.queue_free()

	# 2 Rebuild Roster (Left Side)
	for dog in GlobalState.master_dog_roster:
		var btn = Button.new()
		btn.text = "%s (Energy: %d)" % [dog.name, dog.energy]

		# REFACTORED: Check if this specific resource instance is selected
		var is_selected = (selected_dog == dog)
		#Disable if exhausted, sleeping, OR already selected
		if dog.energy < 20.0 or dog.is_sleeping or is_selected:
			btn.disabled = true
			#btn.visible = false
			if is_selected:
				btn.text += " (Selected)"
		else:
			btn.pressed.connect(_on_roster_dog_selected.bind(dog))

		roster_list.add_child(btn)


# REFACTORED: Renders either nothing or our single chosen choice on the right panel
func _rebuild_selected_dog() -> void:
	for child in team_list.get_children():
		child.queue_free()

	if selected_dog != null:
		var btn = Button.new()
		btn.text = "Remove %s" % selected_dog.name
		btn.pressed.connect(_on_remove_dog_pressed)
		team_list.add_child(btn)


func _on_roster_dog_selected(dog: DogResource) -> void:
	selected_dog = dog
	_refresh_ui()


# REFACTORED: Clears the item out completely
func _on_remove_dog_pressed() -> void:
	selected_dog = null
	_refresh_ui()
