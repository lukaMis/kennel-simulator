extends Node

signal shift_started()
signal shift_ended()

#	packages to inspec in current work shift
var shift_quota: int = GameConstants.CUSTOMS_QUOTA
#	tracks shift payout with boosts and penalties included
var shift_current_payout: int = GameConstants.CUSTOMS_BASE_PAYOUT
#	dogs and packages for current work shift
var active_shift_roster: Array[DogResource] = []
var active_queue: Array[CargoPackage] = []


# Step 1: The modal drops off the dogs here right before transit
func set_shift_team(team: Array[DogResource]) -> void:
	active_shift_roster = team.duplicate()


# Step 2: Called ONLY when the Customs Inspector scene has completely loaded
func initialize_shift_session() -> void:
	print("CustomsInspectionManager: Scene is ready. Running setup logic...")
	_generate_shift_queue()

	# Safe to emit now! The scene is listening.
	#shift_started.emit()
	#print("Shift has started")


func start_shift() -> void:
	shift_started.emit()
	print("Shift has started")
	pass


# The UI modal passes the team directly into this function
#func start_shift(team: Array[DogResource]) -> void:
## 1. Store the shallow clone of the working dogs
#active_shift_roster = team.duplicate()
#
## 2. Build the cargo queue
#_generate_shift_queue()
#
#shift_started.emit()
#print("Shift has started")
#func stop_shift() -> void:
## placeholder for end of shift cleanup
#_clear_shift()
#shift_ended.emit()
#print("Shift has ended")
#pass
func _generate_shift_queue() -> void:
	print("CustomsCargoManager: Generating cargo queue...")
	active_queue.clear()

	#shift_quota = GameConstants.CUSTOMS_QUOTA
	#shift_current_payout = GameConstants.CUSTOMS_BASE_PAYOUT

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

	#func _clear_shift() -> void:
	#active_shift_roster.clear()
	#active_queue.clear()
	## Reset payout/quota to baseline
	#shift_current_payout = GameConstants.CUSTOMS_BASE_PAYOUT
	#shift_quota = GameConstants.CUSTOMS_QUOTA
	#print("CustomsInspectionManager: Shift cleaned up.")
