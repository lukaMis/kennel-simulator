extends Control

@onready var label = $VBoxContainer/Label
@onready var progress_bar = $VBoxContainer/ProgressBar


# 2. A function called ONCE when the dog first boots up to set the text and bar
func setup_display(label_text: String, progress_bar_value: int) -> void:
	label.text = label_text
	progress_bar.value = progress_bar_value


# 3. A function called every timer tick to update just the bar's value
func update_progress_bar(new_value: int) -> void:
	progress_bar.value = new_value
