extends Node

signal shift_started()
signal shift_ended()

#	Total of packages to inspec in current work shift
var shift_quota: int = GameConstants.CUSTOMS_QUOTA
#	tracks shift payout with boosts and penalties included
var shift_current_payout: int = GameConstants.CUSTOMS_BASE_PAYOUT
#	dogs and packages for current work shift
var active_shift_dog: DogResource = null
var active_queue: Array[CargoPackage] = []


# The modal drops off dog for the work shift here right before scene transit
func set_shift_dog(dog: DogResource) -> void:
	active_shift_dog = dog


# Step 2: Called ONLY when the Customs Inspector scene has completely loaded
func initialize_shift_session() -> void:
	print("CustomsInspectionManager: Scene is ready. Running setup logic...")
	_generate_shift_queue()


func start_shift() -> void:
	shift_started.emit()
	print("Shift has started")


func stop_shift() -> void:
	_clear_shift()
	shift_ended.emit()
	print("Shift has ended")


# Add this at the bottom of customs_inspection_manager.gd
func remove_inspected_package() -> void:
	if not active_queue.is_empty():
		# pop_front() removes the item at index 0 and shifts everything else down
		active_queue.pop_front()


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
				package.contraband_type = "Weapons"
			else:
				package.contraband_type = "Drugs"

		active_queue.append(package)
	print("CustomsCargoManager: Successfully generated ", active_queue.size(), " items.")


func _clear_shift() -> void:
	active_shift_dog = null
	active_queue.clear()
	# Reset payout/quota to baseline
	shift_current_payout = GameConstants.CUSTOMS_BASE_PAYOUT
	shift_quota = GameConstants.CUSTOMS_QUOTA
	print("CustomsInspectionManager: Shift cleaned up.")
