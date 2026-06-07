extends Control

@onready var label_info_bar = $LabelInfoBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalState.game_info_update.connect(info_bar_update)
	GlobalState.game_info_change(GlobalState.game_info)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func info_bar_update(new_info: String):
	label_info_bar.text = GlobalState.game_info
	pass
