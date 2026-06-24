extends Node

# A signal that fires whenever money changes, so any UI can update automatically!
signal cash_changed(new_amount: int)
# A signal that fires whenever something in game changes, so any UI can update automatically!
signal game_info_update(new_game_info: String)
signal run_state_changed(game_is_running: bool)

# This creates the slot in the Inspector for you to drag and drop your files
@export var starting_dogs: Array[DogResource] = []

# The master list of all dogs you own. This survives all scene changes!
# This remains your working list that survives scene changes
var master_dog_roster: Array[DogResource] = []
#
var cash: int = GameConstants.STARTING_CASH
var game_info: String = "Try to look after your dogs as best as you can!"
# NEW: The in-memory buffer tracking all gameplay logs
var log_history: Array[String] = []
var game_is_running: bool = true


func _ready() -> void:
	# Duplicate the exported array into your master roster.
	# We use .duplicate() so if dogs gain/lose energy, it doesn't accidentally
	# overwrite your default resource files in the editor!
	master_dog_roster.clear()
	for dog in starting_dogs:
		# duplicate(true) ensures sub-resources are also cloned
		master_dog_roster.append(dog.duplicate(true))

	# Clear out any logs from a previous play session by opening with WRITE mode
	var file = FileAccess.open(GameConstants.LOG_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_line("=== Simulation Session Started ===")
		file.close()

	# 2. Seed our in-memory array with the session start header
	log_history.append("=== Simulation Session Started ===")


# Called automatically by Godot when the game engine shuts down/closes
func _exit_tree() -> void:
	save_logs_to_disk()


func try_spend_money(spend_amount: int) -> bool:
	if cash >= spend_amount:
		cash -= spend_amount

		game_info_change("Spent $" + str(spend_amount) + ". Wallet: $" + str(cash))
		# Notify the world that cash changed!
		cash_changed.emit(cash)
		print("GlobalState.cash: ", cash)

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


# Helper function to dump the entire array history to disk
func save_logs_to_disk() -> void:
	var file = FileAccess.open(GameConstants.LOG_FILE_PATH, FileAccess.WRITE)
	if file:
		for line in log_history:
			file.store_line(line)
		file.close()
		print("GlobalState: Logs successfully flushed to disk storage.")


func set_game_running(running: bool) -> void:
	if game_is_running != running:
		game_is_running = running
		run_state_changed.emit(game_is_running)
