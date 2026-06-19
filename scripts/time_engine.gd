extends Node

# --- SIGNALS (The Cosmic Broadcasts) ---
signal minute_passed(current_minute: int)
signal hour_passed(current_hour: int)
signal day_passed(current_day: int)
signal time_formatted_updated(time_string: String) # Great for updating a UI clock instantly

# --- SIMULATION PACING ---
# If multiplier is 60.0, then 1 real-world second = 1 in-game minute
@export var time_multiplier: float = 60.0

# --- TIME VARIABLES ---
var minute: int = 0
var hour: int = 8 # Let's start the workday at 8:00 AM
var day: int = 1
var _internal_timer: float = 0.0
var _time_is_ticking: bool = true


func _ready() -> void:
	_time_is_ticking = GlobalState.game_is_running
	GlobalState.run_state_changed.connect(_on_game_running_state)


func _process(delta: float) -> void:
	if not _time_is_ticking:
		return
	# Delta is the fraction of a second since the last frame.
	# We multiply it by our simulation speed and add it to our accumulator.
	_internal_timer += delta * time_multiplier

	# Once our internal timer hits 60 "seconds", a simulation minute has passed!
	while _internal_timer >= 60.0:
		_internal_timer -= 60.0
		_advance_minute()


func _advance_minute() -> void:
	#var time_string = "Day %d - %02d:%02d" % [day, hour, minute]
	#GlobalState.game_info_change("Current game time:" + " " + time_string)
	minute += 1
	if minute >= 60:
		minute = 0
		_advance_hour()

	minute_passed.emit(minute)
	_broadcast_formatted_time()


func _advance_hour() -> void:
	hour += 1
	if hour >= 24:
		hour = 0
		_advance_day()

	hour_passed.emit(hour)
	#var time_string = "Day %d - %02d:%02d" % [day, hour, minute]
	#GlobalState.game_info_change("Current game time:" + " " + time_string)


func _advance_day() -> void:
	day += 1
	day_passed.emit(day)


func _broadcast_formatted_time() -> void:
	# Formats the time into a clean "Day 1 - 08:05" string
	var time_string = "Day %d - %02d:%02d" % [day, hour, minute]
	time_formatted_updated.emit(time_string)
	#GlobalState.game_info_change("Current game time:" + " " + time_string)


func _on_game_running_state(game_is_running: bool) -> void:
	_time_is_ticking = game_is_running
