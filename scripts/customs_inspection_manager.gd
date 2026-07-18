extends Node

signal shift_started()
signal shift_ended()

# --- SHIFT TRACKING ---
#	tracks shift payout with boosts and penalties included
var shift_quota: int = GameConstants.CUSTOMS_QUOTA
#	tracks shift payout with boosts and penalties included
var shift_current_payout: int = GameConstants.CUSTOMS_BASE_PAYOUT

# --- SHIFT DATA ---
#	dogs and packages for current work shift
var active_shift_dog: DogResource = null
var active_queue: Array[CargoPackage] = []
# NEW: Temporary memory for the current shift
var shift_inspections: int = 0
var shift_successes: int = 0
var shift_mistakes: int = 0
var shift_contraband_seized: int = 0

# --- Session Stats (NOT exported, so they reset automatically) ---
var current_synergy_multiplier: float = 1.0
var current_confidence_level: int = 1
var check_again_uses: int = 2


# The modal drops off dog for the work shift here right before scene transit
func set_shift_dog(dog: DogResource) -> void:
	active_shift_dog = dog


# Step 2: Called ONLY when the Customs Inspector scene has completely loaded
func initialize_shift_session() -> void:
	print("CustomsInspectionManager: Scene is ready. Running setup logic...")
	_generate_shift_queue()


func start_shift() -> void:
	# Set baseline stats internally instead of using resources
	current_synergy_multiplier = 1.0
	check_again_uses = 2

	if active_shift_dog != null:
		current_confidence_level = 1 if active_shift_dog.handler_bond < 5 else 2

	shift_started.emit()
	print("Shift has started")


func stop_shift() -> void:
	# 1. Bank the money BEFORE clearing the shift data!
	GlobalState.add_money(shift_current_payout)
	GlobalState.player_stats.total_lifetime_earnings += shift_current_payout

	# 2. Now wipe the shift memory clean
	_clear_shift()

	print("Shift has ended")
	shift_ended.emit()


# --- THE CORE MATH ENGINE ---
func process_inspection_choice(is_doubting: bool) -> Dictionary:
	var current_package = active_queue[0]
	var is_correct: bool = (is_doubting == current_package.is_contraband)

	# --- ADD THIS: Log the outcome for the CURRENT SHIFT ---
	shift_inspections += 1
	if is_correct:
		shift_successes += 1
		if current_package.is_contraband:
			shift_contraband_seized += 1
	else:
		shift_mistakes += 1

	# 1. Update Permanent Stats (Dog and Player methods)
	active_shift_dog.record_inspection_result(is_correct)
	GlobalState.player_stats.update_career_stats(is_correct, current_package.is_contraband)

	# 2. Calculate Math Modifiers & Confidence
	var outcome_key: String = ""

	if is_correct:
		current_synergy_multiplier += 0.1
		current_confidence_level = min(current_confidence_level + 1, 3)

		outcome_key = "correct_seize" if is_doubting else "correct_pass"
	else:
		current_synergy_multiplier = 1.0
		current_confidence_level = max(current_confidence_level - 1, 1)
		outcome_key = "wrong_seize" if is_doubting else "wrong_pass"

	# 3. Fetch the String Feedback
	var dog_reaction = active_shift_dog.outcome_reactions.get(outcome_key, "")
	var package_feedback = current_package.outcome_reactions.get(outcome_key, "")

	# --- FIX: CALL THE REMOVAL HERE ---
	_remove_inspected_package()

	# --- ADD THIS: Update the payout based on the NEW multiplier ---
	shift_current_payout = int(GameConstants.CUSTOMS_BASE_PAYOUT * current_synergy_multiplier)

	# 5. Package the data up for the "Dumb" UI
	return {
		"multiplier": CustomsInspectionManager.current_synergy_multiplier,
		"payout": shift_current_payout,
		"dog_reaction": dog_reaction,
		"feedback": package_feedback,
		"is_queue_empty": active_queue.is_empty(),
	}


# 4. Mutate the Queue (Remove the package AFTER it is inspected)
func _remove_inspected_package() -> void:
	if not active_queue.is_empty():
		active_queue.pop_front()
		# Add this line:
		print("DEBUG: Queue size is now ", active_queue.size())
	else:
		print("DEBUG: Queue was already empty!")


func _generate_shift_queue() -> void:
	print("CustomsCargoManager: Generating cargo queue...")
	active_queue.clear()

	shift_quota = GameConstants.CUSTOMS_QUOTA
	shift_current_payout = GameConstants.CUSTOMS_BASE_PAYOUT

	# The manager just loops and commands packages to exist;
	# the packages handle their own internal data layout!
	for i in range(shift_quota):
		active_queue.append(CargoPackage.new())

	print("CustomsCargoManager: Successfully generated ", active_queue.size(), " items.")


func _clear_shift() -> void:
	active_shift_dog = null
	active_queue.clear()
	shift_current_payout = GameConstants.CUSTOMS_BASE_PAYOUT
	shift_quota = GameConstants.CUSTOMS_QUOTA

	# ADD THESE LINES to wipe the shift memory clean
	shift_inspections = 0
	shift_successes = 0
	shift_mistakes = 0
	shift_contraband_seized = 0

	print("CustomsInspectionManager: Shift cleaned up.")
