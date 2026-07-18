extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# --- MODAL LOGIC ---
#func _on_end_shift_pressed() -> void:
## 1. Log that the shift is officially completed!
#GlobalState.player_stats.total_inspector_games_played += 1
#
## 2. Build the text block by reading directly from the player's global stats
#var stats_text = "--- SHIFT COMPLETE ---\n\n"
#stats_text += "--- PLAYER CAREER MILESTONES ---\n"
#stats_text += "Total Shifts Worked: %d\n" % GlobalState.player_stats.total_inspector_games_played
#stats_text += "Total Packages Inspected: %d\n" % GlobalState.player_stats.total_inspections
#stats_text += "Successful Verdicts: %d\n" % GlobalState.player_stats.total_successful_inspections
#stats_text += "Mistakes Made: %d\n" % GlobalState.player_stats.total_failed_inspections
#stats_text += "Contraband Seized: %d\n" % GlobalState.player_stats.total_contraband_seized
#
## 3. Apply the text to your modal's label
#label_shift_summary.text = stats_text
#
## 4. Show the modal overlay!
#end_shift_modal.show()
