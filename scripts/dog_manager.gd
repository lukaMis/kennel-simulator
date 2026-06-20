extends HBoxContainer

@export var array_of_dogs: Array[DogResource] = []
@export var dog_ui_template: PackedScene

# Keep an internal list of the UI nodes we spawn so we can update them later
var active_uis: Array[Control] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 2. Loop through the array and build the kennel automatically
	for dog_data in array_of_dogs:
		_spawn_dog(dog_data)

	# NEW: Tune into the cosmic broadcast!
	# Every time the TimeEngine emits an hour_passed signal, tick the dogs.
	TimeEngine.hour_passed.connect(_on_time_engine_hour_passed)
	# Listen directly to the TimeEngine for the morning whistle
	TimeEngine.morning_started.connect(wake_and_rest_all_dogs)


func wake_and_rest_all_dogs() -> void:
	for dog in array_of_dogs:
		dog.wake_and_rest_dog()

		# Update visual bars for all UIs
	for ui in active_uis:
		ui.update_ui()
	pass


func _spawn_dog(dog_data: DogResource) -> void:
	# Instantiate a brand new DogUI scene from the template
	var new_ui = dog_ui_template.instantiate()

	# Add it as a child of this HBoxContainer so it shows up on screen
	add_child(new_ui)

	# Pass the data in, just like you used to do in Main
	new_ui.setup_dog(dog_data)

	# Save a reference to this UI so we can call update_ui() on it later
	active_uis.append(new_ui)


func _on_time_engine_hour_passed(_current_hour: int) -> void:
	# Tick stats for all data files
	for dog_data in array_of_dogs:
		dog_data.tick_stats()

		# Optional: Keep the console prints for debugging!
		print(dog_data.name, " Hunger: ", dog_data.hunger)

	# Update visual bars for all UIs
	for ui in active_uis:
		ui.update_ui()
