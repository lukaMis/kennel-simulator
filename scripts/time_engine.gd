extends Node

# --- SIGNALS (The Cosmic Broadcasts) ---
signal minute_passed(current_minute: int)
signal hour_passed(current_hour: int)
signal day_passed(current_day: int)
signal morning_started # NEW: Fires exactly when the new workday begins!

signal game_time_update(time_data: Dictionary)

# --- SIMULATION PACING ---
# If multiplier is 60.0, then 1 real-world second = 1 in-game minute
@export var time_multiplier: float = 60.0

# --- TIME VARIABLES ---
var minute: int = 0
var hour: int = 8 # Let's start the workday at 8:00 AM
var day: int = 1
var _internal_timer: float = 0.0
var _time_is_ticking: bool = true

var time_data: Dictionary = {
	"day": 0,
	"hour": 0,
	"minute": 0,
}


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


func start_morning() -> void:
	hour = 8
	minute = 0
	_internal_timer = 0.0
	_broadcast_game_time()
	# Tell the game world it's time to wake up
	morning_started.emit()


func _advance_minute() -> void:
	minute += 1
	if minute >= 60:
		minute = 0
		_advance_hour()

	minute_passed.emit(minute)
	_broadcast_game_time()


func _advance_hour() -> void:
	hour += 1
	if hour >= 24:
		hour = 0
		_advance_day()

	hour_passed.emit(hour)


func _advance_day() -> void:
	day += 1
	day_passed.emit(day)


func _broadcast_game_time() -> void:
	# This updates the existing dictionary instead of making a new one!
	time_data.day = day
	time_data.hour = hour
	time_data.minute = minute

	game_time_update.emit(time_data)
	#print(time_data)


func _on_game_running_state(game_is_running: bool) -> void:
	_time_is_ticking = game_is_running
	#stop game engine to run _process() if gaame is not running
	if game_is_running:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func advance_game_hours(hours_to_add: int) -> void:
	hour += hours_to_add
	_broadcast_game_time()
