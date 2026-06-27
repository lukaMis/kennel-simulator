class_name CargoPackage
extends RefCounted

var is_contraband: bool = false
var contraband_type: String = "Safe"
var visual_sprite_id: int = 1


# The constructor runs automatically whenever CargoPackage.new() is called
func _init() -> void:
	visual_sprite_id = randi_range(1, 4)

	if randf() < GameConstants.CUSTOMS_CONTRABAND_CHANCE:
		is_contraband = true
		if randf() < 0.5:
			contraband_type = "Weapons"
		else:
			contraband_type = "Drugs"
