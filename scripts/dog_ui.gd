extends Control

var dog: DogResource
@onready var hunger_bar = $VBoxContainer/HungerBar
@onready var hunger_label = $VBoxContainer/LabelHunger

@onready var energy_bar = $VBoxContainer/EnergyBar
@onready var energy_label = $VBoxContainer/LabelEnergy

@onready var button_feed = $VBoxContainer/ButtonFeed
@onready var button_sleep = $VBoxContainer/ButtonSleep
@onready var button_work = $VBoxContainer/ButtonWork

@onready var hunger_ui = $VBoxContainer2/HungerUI
@onready var energy_ui = $VBoxContainer2/EnergyUI
@onready var button_work2 = $VBoxContainer2/ButtonWork2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_sleep.toggle_mode = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup_dog_old(dog_data: DogResource):
	dog = dog_data

	hunger_bar.value = dog.hunger
	energy_bar.value = dog.energy

	hunger_label.text = dog.name + " hunger:"
	energy_label.text = dog.name + " energy:"

	button_feed.text = "Feed " + dog.name

	button_sleep.button_pressed = dog.is_sleeping
	button_sleep.text = dog.name + " is awake"
	button_work.text =  dog.name + " Go work"
	pass

func setup_dog(dog_data: DogResource) -> void:
	dog = dog_data

	hunger_ui.setup_hunger(dog)
	energy_ui.setup_energy(dog)
	button_work2.text = dog.name + " Go Fetch"
	pass

#func update_ui():
	#if dog:
		#hunger_bar.value = dog.hunger
		#energy_bar.value = dog.energy
#
		#if dog.is_sleeping and dog.energy == 100:
			#_handle_dog_sleep(false)
		#if !dog.is_sleeping and dog.energy == 0:
			#_handle_dog_sleep(true)
		#pass

func update_ui() -> void:
	if dog:
		hunger_ui.update_hunger_ui()
		energy_ui.update_energy_ui() # <--- This calls your function!
		if dog.is_sleeping and dog.energy == 100:
			_force_sleep_switch(false)
			GlobalState.game_info_change(dog.name + " woke up fully rested!")
		if !dog.is_sleeping and dog.energy == 0:
			_force_sleep_switch(true)
			GlobalState.game_info_change(dog.name + " passed out from exhaustion!")
	pass

func _force_sleep_switch(is_sleeping: bool) -> void:
	# Reaches into EnergyUI and forces it to visually flip its CheckButton
	energy_ui.force_sleep_state(is_sleeping)
	pass

func _on_button_feed_pressed() -> void:
	if dog and !dog.is_sleeping:
		# Talk directly to the GlobalState singleton!
		if GlobalState.try_spend_money(GameConstants.FOOD_COST):
			dog.hunger = min(dog.hunger + GameConstants.FEED_HUNGER_GAIN, 100)
			hunger_bar.value = dog.hunger
			print(dog.name + " just got food, hunger is now: ", dog.hunger)
			GlobalState.game_info_change(dog.name + " just got food, hunger is now: " + str(dog.hunger))
	if dog and dog.is_sleeping:
		GlobalState.game_info_change(dog.name + " is sleeping can NOT eat!")
	pass # Replace with function body.

func _on_button_sleep_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_handle_dog_sleep(true)
	else:
		_handle_dog_sleep(false)
	pass # Replace with function body.

func _handle_dog_sleep(toggled_on:bool):
	dog.is_sleeping = toggled_on
	button_sleep.button_pressed = toggled_on

	if toggled_on:
		button_sleep.text = dog.name + " is sleeping"
	else:
		button_sleep.text = dog.name + " is awake"

	print(dog.name, " sleeping state changed to: ", toggled_on)
	GlobalState.game_info_change(dog.name + " sleeping " + str(toggled_on))
	pass

func _on_button_work_pressed() -> void:
	if !dog:
		return
	if dog.is_sleeping:
		print(dog.name + " is sleeping, can NOT work.")
		GlobalState.game_info_change(dog.name + " is sleeping, can NOT work!")
		return
	if dog.energy < GameConstants.WORK_ENERGY_COST:
		print(dog.name, " is too exhausted to work!")
		GlobalState.game_info_change(dog.name + " is too exhausted to work!")
		return

	# If checks pass, execute the action!
	dog.energy -= GameConstants.WORK_ENERGY_COST
	energy_bar.value = dog.energy
	# Reward the player globally!
	GlobalState.add_money(GameConstants.WORK_PAYOUT)
	print(dog.name, " successfully fetched items! You earned: ", GameConstants.WORK_PAYOUT)
	GlobalState.game_info_change(dog.name + " successfully fetched items! You earned: " + str(GameConstants.WORK_PAYOUT))
	pass # Replace with function body.



func _on_button_work_2_pressed() -> void:
	if !dog:
		return
	if dog.is_sleeping:
		print(dog.name + " is sleeping, can NOT work.")
		GlobalState.game_info_change(dog.name + " is sleeping, can NOT work!")
		return
	if dog.energy < GameConstants.WORK_ENERGY_COST:
		print(dog.name, " is too exhausted to work!")
		GlobalState.game_info_change(dog.name + " is too exhausted to work!")
		return

	# If checks pass, execute the action!
	dog.energy -= GameConstants.WORK_ENERGY_COST
	energy_ui.update_energy_ui()
	pass # Replace with function body.
