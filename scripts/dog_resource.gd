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
@export var tell_reactions: Dictionary = {
	1: { true: "dog_subtle_sniff", false: "dog_looks_away" },
	2: { true: "dog_alert_posture", false: "dog_calm_standing" },
	3: { true: "dog_aggressive_bark", false: "dog_happy_sit" },
}
@export var outcome_reactions: Dictionary = {
	"correct_seize": "dog_excited_wag",
	"correct_pass": "dog_relieved_sigh",
	"wrong_seize": "dog_confused_tilt",
	"wrong_pass": "dog_cowering_shame",
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
