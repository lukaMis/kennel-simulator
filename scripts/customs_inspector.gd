extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1. Connect any local UI elements to the manager signals right here if needed
	CustomsInspectionManager.shift_started.connect(_on_shift_started)
	CustomsInspectionManager.shift_ended.connect(_on_shift_ended)

	# 2. Tell the manager it is safe to spin up the gameplay logic
	CustomsInspectionManager.initialize_shift_session()

	# 3. Pull the data cleanly to populate your UI
	var working_dogs = CustomsInspectionManager.active_shift_roster
	var packages_to_check = CustomsInspectionManager.active_queue

	print("Inspector Scene: Loaded successfully with ", working_dogs.size(), " dogs.")
	print("Inspector Scene: Loaded successfully with ", packages_to_check.size(), " packages.")
	CustomsInspectionManager.start_shift()
	#Run your instantiation/spawning visual loops below...


func _on_shift_started() -> void:
	pass


func _on_shift_ended() -> void:
	pass
