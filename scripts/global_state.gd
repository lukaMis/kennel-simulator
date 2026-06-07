extends Node

var cash: int = GameConstants.STARTING_CASH
var game_info : String = "Try to look after your dogs as best as you can!"

# A signal that fires whenever money changes, so any UI can update automatically!
signal cash_changed(new_amount: int)
# A signal that fires whenever something in game changes, so any UI can update automatically!
signal game_info_update(new_game_info: String)

func try_spend_money(spend_amount:int):
	if cash >= spend_amount:
		cash -= spend_amount
		# Notify the world that cash changed!
		cash_changed.emit(cash)
		print("GlobalState.cash: ", cash)
		game_info_change("GlobalState.cash: " + str(cash))
		return true

	print("GlobalState: Not enough cash!")
	game_info_change("GlobalState: Not enough cash!")
	return false

func add_money(amount: int) -> void:
	cash += amount
	cash_changed.emit(cash)
	print("GlobalState: Earned $", amount, ". Total: $", cash)
	game_info_change("GlobalState: Earned: " + str(amount) + " Total: " + str(cash))
	pass

func game_info_change(new_game_info: String):
	game_info = new_game_info
	game_info_update.emit(game_info)
	pass
