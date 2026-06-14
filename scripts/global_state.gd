extends Node

var cash: int = GameConstants.STARTING_CASH
var game_info: String = "Try to look after your dogs as best as you can!"
# NEW: The in-memory buffer tracking all gameplay logs
var log_history: Array[String] = []

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
	# 2. Seed our in-memory array with the session start header
	log_history.append("=== Simulation Session Started ===")


func try_spend_money(spend_amount: int) -> bool:
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


func game_info_change(new_game_info: String) -> void:
	game_info = new_game_info
	game_info_update.emit(game_info)

	# 1. Grab system time and format the string
	var time = Time.get_time_dict_from_system()
	var timestamp = "[%02d:%02d:%02d] " % [time.hour, time.minute, time.second]
	var log_line = timestamp + new_game_info

	# 2. Push directly to memory array (Super fast!)
	log_history.append(log_line)

	# 3. Crash Guard: Batch flush to disk every 15 entries automatically
	if log_history.size() % 15 == 0:
		save_logs_to_disk()


# Called automatically by Godot when the game engine shuts down/closes
func _exit_tree() -> void:
	save_logs_to_disk()


# Helper function to dump the entire array history to disk
func save_logs_to_disk() -> void:
	var file = FileAccess.open(GameConstants.LOG_FILE_PATH, FileAccess.WRITE)
	if file:
		for line in log_history:
			file.store_line(line)
		file.close()
		print("GlobalState: Logs successfully flushed to disk storage.")
