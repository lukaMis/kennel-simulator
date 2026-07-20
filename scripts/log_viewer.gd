extends Control

@onready var modal_panel: PanelContainer = $ModalPanel
@onready var label_contents: Label = $ModalPanel/VBoxContainer/ScrollContainer/LabelContents
@onready var button_log_open: Button = $ButtonLogOpen
@onready var scroll_container: ScrollContainer = $ModalPanel/VBoxContainer/ScrollContainer


func _ready() -> void:
	# Guarantee it starts hidden
	modal_panel.hide()
	# 1. Connect to the global signal the second this node enters the game world!
	GlobalState.game_info_update.connect(_on_global_info_update)


# NEW: This runs automatically every time GlobalState.game_info_change() is called anywhere
func _on_global_info_update(new_info: String) -> void:
	if modal_panel.visible:
		# REFACTORED: No time dict lookup needed! Grab the pre-formatted line from memory.
		if not GlobalState.log_history.is_empty():
			label_contents.text += "\n" + GlobalState.log_history[-1]
		# 3. Snap down
		_scroll_to_bottom()


# Connected from ButtonLogOpen's pressed() signal
func _on_button_log_open_pressed() -> void:
	_refresh_log_text() # Load the text right before showing it
	modal_panel.show()
	button_log_open.hide()
	_scroll_to_bottom() # Scroll to the bottom immediately when opened!


func _on_button_log_close_pressed() -> void:
	modal_panel.hide()
	button_log_open.show()


# REFACTORED: Completely memory-based optimization
func _refresh_log_text() -> void:
	# Joins all lines in our array with newlines instantly. No file lookups required!
	label_contents.text = "\n".join(GlobalState.log_history)


# NEW: The asynchronous scrolling machine
func _scroll_to_bottom() -> void:
	# CRITICAL: Wait exactly 1 frame so Godot can process the text block resize!
	await get_tree().process_frame
	# Fetch the dynamic maximum height of the vertical scrollbar and jump to it
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

	# 1. Print an Autoload (Singleton)
	print_object_variables(GlobalState, "GlobalState")
	# 2. Print a specific Player Resource (assuming it lives inside GlobalState)

	print_object_variables(GlobalState.player_stats, "Player Stats Resource")

	# 3. Print a specific DogResource from your roster
	var dog_1 = GlobalState.master_dog_roster[0]
	print_object_variables(dog_1, "DogResource: " + dog_1.name)
	var dog_2 = GlobalState.master_dog_roster[1]
	print_object_variables(dog_2, "DogResource: " + dog_2.name)
	var dog_3 = GlobalState.master_dog_roster[2]
	print_object_variables(dog_3, "DogResource: " + dog_3.name)

	# 4. Print the active shift Manager
	print_object_variables(CustomsInspectionManager, "Customs Manager")

	# 4. Print the Main
	print_object_variables(self, "Main")

	# 4. Print the Time engine
	print_object_variables(TimeEngine, "TimeEngine")

	# 4. Print the GameConstants
	print_object_variables(GameConstants, "GameConstants")


func print_object_variables(target_object: Object, label: String = "Object") -> void:
	print("--- LISTING VARIABLES FOR: ", label, " ---")

	# Failsafe in case you pass an empty variable
	if target_object == null:
		print("ERROR: Provided object is null.")
		print("----------------------------------------\n")
		return

	# Ask the target object for its properties
	var properties = target_object.get_property_list()
	var found_vars = 0

	for prop in properties:
		# Filter to ONLY show variables defined in the script
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var var_name = prop.name
			# Ask the target object for the value of this specific variable
			var var_value = target_object.get(var_name)

			print(var_name, ": ", var_value)
			found_vars += 1

	if found_vars == 0:
		print("No custom script variables found.")

	print("----------------------------------------\n")
