class_name PlayerResource
extends Resource

# --- Permanent Stats (Exported for saving) ---
@export var total_inspector_games_played: int = 0
@export var total_inspections: int = 0
@export var total_successful_inspections: int = 0
@export var total_failed_inspections: int = 0
@export var total_contraband_seized: int = 0

# --- Session Stats (NOT exported, so they reset automatically) ---
var current_synergy_multiplier: float = 1.0
var check_again_uses: int = 2


# Methods to handle logic
func reset_session():
	current_synergy_multiplier = 1.0
	check_again_uses = 2


func update_career_stats(was_success: bool, is_contraband: bool):
	total_inspections += 1
	if was_success:
		total_successful_inspections += 1
		if is_contraband:
			total_contraband_seized += 1
	else:
		total_failed_inspections += 1
