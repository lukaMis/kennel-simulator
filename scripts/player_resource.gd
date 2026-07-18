class_name PlayerResource
extends Resource

# --- Permanent Stats (Exported for saving) ---
@export var total_inspector_games_played: int = 0
@export var total_inspections: int = 0
@export var total_successful_inspections: int = 0
@export var total_failed_inspections: int = 0
@export var total_contraband_seized: int = 0

var total_lifetime_earnings: int = 0


func update_career_stats(is_correct: bool, is_contraband: bool) -> void:
	# 1. Always log that an inspection happened
	total_inspections += 1

	# 2. Log the win or loss
	if is_correct:
		total_successful_inspections += 1

		# 3. Only count contraband if it was actually seized
		if is_contraband:
			total_contraband_seized += 1
	else:
		total_failed_inspections += 1
