extends Control

@onready var progress_display = $VBoxContainer/ProgressDisplay
@onready var button_sleep = $VBoxContainer/ButtonSleep

var _dog: DogResource # Keep a reference to this specific dog's data

func setup_energy(dog_data: DogResource):
	_dog = dog_data
	progress_display.setup_display(_dog.name + " Energy: ", _dog.energy)
	button_sleep.text = "Put " + _dog.name + " to sleep"
	pass

func update_energy_ui() -> void:
	if _dog:
		# Because step 1 already lowered the number in memory,
		# _dog.energy is naturally 95 right now!
		progress_display.update_value(_dog.energy)
	pass

# 3. Public helper function so DogUI can force the switch to flip (like passing out or waking up automatically)
func force_sleep_state(should_sleep: bool) -> void:
	_dog.is_sleeping = should_sleep
	button_sleep.set_pressed_no_signal(should_sleep)
	_update_button_text(should_sleep)
	pass

func _on_button_sleep_toggled(toggled_on: bool) -> void:
	if not _dog:
		return
	_dog.is_sleeping = toggled_on
	_update_button_text(toggled_on)
	# Tell the global info bar what just happened!
	GlobalState.game_info_change(_dog.name + " sleeping state changed to: " + str(toggled_on))
	pass # Replace with function body.

# 5. Little internal helper just to swap the button text
func _update_button_text(is_sleeping: bool) -> void:
	if is_sleeping:
		button_sleep.text = "Wake " + _dog.name + " up!"
	else:
		button_sleep.text = "Put " + _dog.name + " to sleep"
	pass
