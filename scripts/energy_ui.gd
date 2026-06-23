extends Control

signal sleep_changed(is_sleeping: bool) # <--- ADD THIS SIGNAL

# Keep a reference to this specific dog's data
var _dog: DogResource

@onready var progress_display = $VBoxContainer/ProgressDisplay
@onready var button_sleep = $VBoxContainer/ButtonSleep


func setup_energy(dog_data: DogResource):
	_dog = dog_data
	progress_display.setup_display(_dog.name + " Energy: ", _dog.energy)
	button_sleep.text = "Put " + _dog.name + " to sleep"


func update_energy_ui() -> void:
	if _dog:
		progress_display.update_progress_bar(_dog.energy)
		force_sleep_state(_dog.is_sleeping)


# 3. Public helper function so DogUI can force the switch to flip (like passing out or waking up automatically)
func force_sleep_state(should_sleep: bool) -> void:
	_dog.is_sleeping = should_sleep

	_update_sleep_button_state(should_sleep)


func _on_button_sleep_toggled(toggled_on: bool) -> void:
	if not _dog:
		return
	_dog.is_sleeping = toggled_on

	_update_sleep_button_state(toggled_on)

	# Tell the global info bar what just happened!
	GlobalState.game_info_change(_dog.name + " sleeping state changed to: " + str(toggled_on))


func _update_sleep_button_state(toggled_on: bool) -> void:
	if toggled_on:
		button_sleep.text = "Wake " + _dog.name + " up!"
	else:
		button_sleep.text = "Put " + _dog.name + " to sleep"

	button_sleep.set_pressed_no_signal(toggled_on)
	sleep_changed.emit(toggled_on)
