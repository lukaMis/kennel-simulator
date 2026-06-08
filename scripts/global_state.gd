extends Node

var cash: int = GameConstants.STARTING_CASH
var game_info : String = "Try to look after your dogs as best as you can!"

# A signal that fires whenever money changes, so any UI can update automatically!
signal cash_changed(new_amount: int)
# A signal that fires whenever something in game changes, so any UI can update automatically!
signal game_info_update(new_game_info: String)

func _ready() -> void:
	# Clear out any logs from a previous play session by opening with WRITE mode
	var file = FileAccess.open(GameConstants.LOG_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_line("=== Simulation Session Started ===")
		file.close()
	pass

func try_spend_money(spend_amount:int):
	if cash >= spend_amount:
		cash -= spend_amount
		# Notify the world that cash changed!
		cash_changed.emit(cash)
		print("GlobalState.cash: ", cash)
		#game_info_change("GlobalState.cash: " + str(cash))
		game_info_change("Spent $" + str(spend_amount) + ". Wallet: $" + str(cash))
		return true
	print("GlobalState: Not enough cash!")
	game_info_change("GlobalState: Not enough cash!")
	return false

func add_money(amount: int) -> void:
	cash += amount
	cash_changed.emit(cash)
	print("GlobalState: Earned $", amount, ". Total: $", cash)
	game_info_change("Earned $" + str(amount) + ". Wallet: $" + str(cash))
	pass

func game_info_change(new_game_info: String) -> void:
	game_info = new_game_info
	game_info_update.emit(game_info)
	# Execute the disk save automatically!
	_append_log_to_file(new_game_info)
	pass

func _append_log_to_file(message: String) -> void:
	# 1. Grab system time dictionary
	var time = Time.get_time_dict_from_system()

	# 2. Format a string like: [20:15:32]
	var timestamp = "[%02d:%02d:%02d] " % [time.hour, time.minute, time.second]
	var log_line = timestamp + message

	# FIX: Use READ_WRITE because Godot 4 dropped the APPEND flag
	var file = FileAccess.open(GameConstants.LOG_FILE_PATH, FileAccess.READ_WRITE)
	if file:
		file.seek_end() # CRITICAL: Move the typing cursor to the very bottom of the file!
		file.store_line(log_line)
		file.close()
	pass
