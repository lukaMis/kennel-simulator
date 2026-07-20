extends CanvasLayer

@onready var variable_list_container: VBoxContainer = %VariableListContainer
@onready var object_selector: OptionButton = %ObjectSelector
@onready var button_close: Button = %ButtonClose

var debug_targets: Dictionary = { }
var current_target: Object = null


func _ready() -> void:
	# CRITICAL: Ensures this menu still works while the rest of the game tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()
	button_close.pressed.connect(close_modal)
	object_selector.item_selected.connect(_on_object_selected)

	# --- REGISTER YOUR GLOBAL OBJECTS HERE ---
	register_target("Game Constants", GameConstants)
	register_target("Global State", GlobalState)
	register_target("Customs Manager", CustomsInspectionManager)
	register_target("GlobalState.player_stats", GlobalState.player_stats)
	register_target("Dog 1", GlobalState.master_dog_roster[0])
	register_target("Dog 2", GlobalState.master_dog_roster[1])
	register_target("Dog 3", GlobalState.master_dog_roster[2])
	register_target("TimeEngine", TimeEngine)


func register_target(label: String, obj: Object) -> void:
	if obj == null:
		return
	debug_targets[label] = obj
	object_selector.add_item(label)

	if current_target == null:
		object_selector.select(0)
		_on_object_selected(0)


func open_modal() -> void:
	if CustomsInspectionManager.active_shift_dog != null:
		register_target("Active Shift Dog", CustomsInspectionManager.active_shift_dog)

	_rebuild_ui()
	show()

	# PAUSE THE GAME COMPLETELY
	get_tree().paused = true


func close_modal() -> void:
	# RESUME THE GAME
	get_tree().paused = false
	hide()

# --- REPLACE YOUR _input() FUNCTION IN DEBUG_MENU.GD WITH THIS ---


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		# Check for Ctrl + D to open or close the menu anywhere in the game
		if Input.is_key_pressed(KEY_CTRL) and event.keycode == KEY_D:
			if visible:
				close_modal()
			else:
				open_modal()

			# Prevent the input event from triggering other game actions underneath
			get_viewport().set_input_as_handled()

		# Allow Escape to close the menu when it's open
		elif visible and event.keycode == KEY_ESCAPE:
			close_modal()
			get_viewport().set_input_as_handled()


func _on_object_selected(index: int) -> void:
	var label_name = object_selector.get_item_text(index)
	if debug_targets.has(label_name):
		current_target = debug_targets[label_name]
		_rebuild_ui()


func _rebuild_ui() -> void:
	for child in variable_list_container.get_children():
		child.queue_free()

	if current_target == null:
		return

	var target_script = current_target.get_script()
	if target_script == null:
		return

	var properties = target_script.get_script_property_list()

	for prop in properties:
		var var_name = prop.name
		var var_type = prop.type
		var current_value = current_target.get(var_name)

		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var label = Label.new()
		label.text = var_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		match var_type:
			TYPE_BOOL:
				var checkbox = CheckBox.new()
				checkbox.button_pressed = current_value
				checkbox.toggled.connect(func(val): current_target.set(var_name, val))
				row.add_child(checkbox)
			TYPE_INT:
				var spinbox = SpinBox.new()
				spinbox.allow_greater = true
				spinbox.allow_lesser = true
				spinbox.rounded = true
				spinbox.value = current_value
				spinbox.value_changed.connect(func(val): current_target.set(var_name, int(val)))
				row.add_child(spinbox)
			TYPE_FLOAT:
				var spinbox = SpinBox.new()
				spinbox.allow_greater = true
				spinbox.allow_lesser = true
				spinbox.step = 0.1
				spinbox.value = current_value
				spinbox.value_changed.connect(func(val): current_target.set(var_name, val))
				row.add_child(spinbox)
			TYPE_STRING:
				var line_edit = LineEdit.new()
				line_edit.text = str(current_value)
				line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				line_edit.text_changed.connect(func(val): current_target.set(var_name, val))
				row.add_child(line_edit)
			_:
				var fallback_label = Label.new()
				fallback_label.text = str(current_value)
				row.add_child(fallback_label)

		variable_list_container.add_child(row)

	#func _input(event: InputEvent) -> void:
	#if Input.is_key_pressed(KEY_CTRL) and event is InputEventKey:
	#if event.keycode == KEY_D and event.is_pressed() and not event.is_echo():
	#DebugMenu.open_modal()
