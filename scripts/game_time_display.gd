extends Control

@onready var game_time_display_label = $GameTimeDisplayLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_time_display_label.text = 'Game Time'
	TimeEngine.game_time_update.connect(_on_game_time_update)


func _on_game_time_update(time_data: Dictionary) -> void:
	# Formats the time into a clean "Game Time: Day 1 - 08:05" string
	var formatted_time_string = 'Game Time: ' + "Day %d - %02d:%02d" % [time_data.day, time_data.hour, time_data.minute]
	game_time_display_label.text = formatted_time_string
