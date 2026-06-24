extends Node

signal shift_started()
signal shift_ended()

var active_shift_roster: Array[DogResource] = []
var active_queue: Array[CargoPackage] = []
var shift_current_payout: int = GameConstants.CUSTOMS_BASE_PAYOUT
var shift_quota: int = GameConstants.CUSTOMS_QUOTA


# The UI modal passes the team directly into this function
func start_shift(team: Array[DogResource]) -> void:
	# 1. Store the shallow clone of the working dogs
	active_shift_roster = team.duplicate()

	# 2. Build the cargo queue
	_generate_shift_queue()

	shift_started.emit()
	print("Shift has started")


func stop_shift() -> void:
	# placeholder for end of shift cleanup
	shift_ended.emit()
	print("Shift has ended")
	pass


func _generate_shift_queue() -> void:
	print("CustomsCargoManager: Generating cargo queue...")
	active_queue.clear()

	shift_quota = GameConstants.CUSTOMS_QUOTA
	shift_current_payout = GameConstants.CUSTOMS_BASE_PAYOUT

	for i in range(shift_quota):
		var package = CargoPackage.new()
		package.visual_sprite_id = randi_range(1, 4)

		if randf() < GameConstants.CUSTOMS_CONTRABAND_CHANCE:
			package.is_contraband = true
			if randf() < 0.5:
				package.contraband_type = "Organic"
			else:
				package.contraband_type = "Mineral"

		active_queue.append(package)

	print("CustomsCargoManager: Successfully generated ", active_queue.size(), " items.")
