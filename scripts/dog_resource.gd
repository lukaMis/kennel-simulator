class_name DogResource
extends Resource

# --- Existing Stats ---
@export var name: String = "Doggy name"
@export var hunger: int = 100
@export var energy: int = 100
@export var is_sleeping: bool = false
@export var hunger_drain_rate: int = 5
@export var energy_drain_rate: int = 5
# --- New Inspection Stats (Permanent) ---
@export var handler_bond: float = 1.0
@export var betrayal_trauma: float = 0.0
@export var personality_trait: String = "Standard"
# --- NEW: Individual Dog Performance Stats ---
@export var total_dog_correct: int = 0
@export var total_dog_wrong: int = 0
# --- Mapping ---
@export var tell_reactions_ORIG: Dictionary = {
	1: { true: "dog subtle sniff", false: "dog looks away" },
	2: { true: "dog alert posture", false: "dog calm standing" },
	3: { true: "dog aggressive bark", false: "dog happy sit" },
}
# FOR DEBUGGING ONLY
@export var tell_reactions: Dictionary = {
	1: { true: "DIRTY", false: "CLEAN" },
	2: { true: "DIRTY", false: "CLEAN" },
	3: { true: "DIRTY", false: "CLEAN" },
}
@export var outcome_reactions: Dictionary = {
	"correct_seize": "dog excited wag",
	"correct_pass": "dog relieved sigh",
	"wrong_seize": "dog confused tilt",
	"wrong_pass": "dog cowering shame",
}

# --- Inspection Stats (Session) ---
var current_confidence_level: int = 1


# --- Existing Methods ---
func tick_stats():
	if is_sleeping:
		energy = min(energy + GameConstants.SLEEP_ENERGY_GAIN, 100)
		hunger = max(hunger - (hunger_drain_rate * 1.5), 0)
	else:
		energy = max(energy - energy_drain_rate, 0)
		hunger = max(hunger - hunger_drain_rate, 0)


func wake_and_rest_dog() -> void:
	is_sleeping = false
	energy = 100


# --- Inspection Methods ---
func reset_session():
	current_confidence_level = 1 if handler_bond < 5 else 2


func increase_confidence():
	current_confidence_level = min(current_confidence_level + 1, 3)


func decrease_confidence():
	current_confidence_level = max(current_confidence_level - 1, 1)


# --- NEW: Tracking Method ---
func record_inspection_result(is_correct: bool):
	if is_correct:
		total_dog_correct += 1
	else:
		total_dog_wrong += 1
