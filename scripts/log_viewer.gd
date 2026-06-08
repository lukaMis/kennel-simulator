extends Control

@onready var modal_panel: PanelContainer = $ModalPanel
@onready var label_contents: Label = $ModalPanel/VBoxContainer/ScrollContainer/LabelContents
@onready var button_log_open: Button = $ButtonLogOpen
@onready var scroll_container: ScrollContainer = $ModalPanel/VBoxContainer/ScrollContainer

func _ready() -> void:
	# Guarantee it starts hidden
	modal_panel.hide()
	# 1. Connect to the global signal the second this node enters the game world!
	GlobalState.game_info_update.connect(_on_global_info_update)
	pass

# NEW: This runs automatically every time GlobalState.game_info_change() is called anywhere
func _on_global_info_update(_new_info: String) -> void:
	# CRITICAL CHECK: Only read from the disk if the player is actively looking at the modal!
	if modal_panel.visible:
		_refresh_log_text()
		_scroll_to_bottom() # Snap downwards when a brand new line updates!
	pass

# Connected from ButtonLogOpen's pressed() signal
func _on_button_log_open_pressed() -> void:
	_refresh_log_text() # Load the text right before showing it
	modal_panel.show()
	button_log_open.hide()
	_scroll_to_bottom() # Scroll to the bottom immediately when opened!
	pass

func _on_button_log_close_pressed() -> void:
	modal_panel.hide()
	button_log_open.show()
	pass

# NEW: We isolated the file-reading logic into its own reusable helper function
func _refresh_log_text() -> void:
	if FileAccess.file_exists(GameConstants.LOG_FILE_PATH):
		var file = FileAccess.open(GameConstants.LOG_FILE_PATH, FileAccess.READ)
		if file:
			label_contents.text = file.get_as_text()
			file.close()
	else:
		label_contents.text = "No log entry file found on disk."
	pass

# NEW: The asynchronous scrolling machine
func _scroll_to_bottom() -> void:
	# CRITICAL: Wait exactly 1 frame so Godot can process the text block resize!
	await get_tree().process_frame
	# Fetch the dynamic maximum height of the vertical scrollbar and jump to it
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	pass
