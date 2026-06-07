extends Control

var dog: DogResource
@onready var hunger_ui = $VBoxContainer/HungerUI
@onready var energy_ui = $VBoxContainer/EnergyUI
@onready var button_work = $VBoxContainer/ButtonWork


func setup_dog(dog_data: DogResource) -> void:
	dog = dog_data

	hunger_ui.setup_hunger(dog)
	energy_ui.setup_energy(dog)
	button_work.text = dog.name + " Go Fetch"
	pass

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
	energy_ui.update_energy_ui()
	# Reward the player globally!
	GlobalState.add_money(GameConstants.WORK_PAYOUT)
	print(dog.name, " successfully fetched items! You earned: ", GameConstants.WORK_PAYOUT)
	GlobalState.game_info_change(dog.name + " successfully fetched items! You earned: " + str(GameConstants.WORK_PAYOUT))
	pass
