extends Control

@onready var game_time_display_label = $GameTimeDisplayLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_time_display_label.text = 'Game Time'
	TimeEngine.time_formatted_updated.connect(_on_game_time_update)
# END

func _on_game_time_update(time_update:String)->void:
	game_time_display_label.text = 'Game Time:' + ' ' + time_update
# END
