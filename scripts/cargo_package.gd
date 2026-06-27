class_name CargoPackage
extends RefCounted

var is_contraband: bool = false
var contraband_type: String = ""
var visual_sprite_id: int = 1
var package_type: String = ""
var package_type_options: Array = ["Business briefcase", "Duffle bag", "Just a bag", "Dog carrier", "Backpack", "School bag"]
var package_owner: String = ""
var package_owner_options: Array = ["Business person", "Family", "Shaddy guy", "Karen", "Smuggler", "Guy with turban", "Bored looking man", "Nervous looking woman", "Just some dude", "Joe Everyday", "Jone Doe", "Nervous person"]
var outcome_reactions: Dictionary = {
	"correct_seize": "Nice, you found and seized package with contraband!",
	"correct_pass": "Correctly passed, NO contraband here!",
	"wrong_seize": "You got it wrong buddy, this package is clean!",
	"wrong_pass": "Ouch, you let the contraband slip by you!",
}


# The constructor runs automatically whenever CargoPackage.new() is called
func _init() -> void:
	visual_sprite_id = randi_range(1, 4)

	package_type = package_type_options.pick_random()
	print('package_type: ', package_type)

	package_owner = package_owner_options.pick_random()
	print('package_owner: ', package_owner)

	if randf() < GameConstants.CUSTOMS_CONTRABAND_CHANCE:
		is_contraband = true
		if randf() < 0.5:
			contraband_type = "Weapons"
		else:
			contraband_type = "Drugs"
