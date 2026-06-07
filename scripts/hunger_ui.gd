extends Control

@onready var progress_display = $VBoxContainer/ProgressDisplay
@onready var button_feed = $VBoxContainer/ButtonFeed

var _dog: DogResource # Keep a reference to this specific dog's data


func setup_hunger(dog_data: DogResource):
	_dog = dog_data
	progress_display.setup_display(_dog.name + " Hunger: ", _dog.hunger)
	button_feed.text = "Feed" + " " + _dog.name
	pass

func update_hunger_ui():
	if _dog:
		progress_display.update_progress_bar(_dog.hunger)
	pass

func _on_button_feed_pressed() -> void:
	if not _dog:
		return

	# If the dog is asleep, stop right here!
	if _dog.is_sleeping:
		GlobalState.game_info_change(_dog.name + " is asleep can NOT eat!")
		return

	# Ask our autoload global wallet if we have enough cash
	if GlobalState.try_spend_money(GameConstants.FOOD_COST):
		_dog.hunger = min(_dog.hunger + GameConstants.FEED_HUNGER_GAIN, GameConstants.MAX_STAT_VALUE)
		progress_display.update_progress_bar(_dog.hunger) # Update the bar instantly!
		print(_dog.name + " just got food, hunger is now: ", _dog.hunger)
		GlobalState.game_info_change(_dog.name + " just got food, hunger is now: " + str(_dog.hunger))
	pass
