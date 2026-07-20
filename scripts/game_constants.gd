extends Node

# --- Economy Constants ---
var STARTING_CASH: int = 22
var FOOD_COST: int = 5
var WORK_PAYOUT: int = 15
var BASE_RENT: int = 5
#
# --- Dogs Constants ---
var WORK_ENERGY_COST: int = 20
var SLEEP_ENERGY_GAIN: int = 10
var FEED_HUNGER_GAIN: int = 10
var VERY_HUNGRY_TRESHOLD: int = 25
var STARTVING_TRESHOLD: int = 0
var MAX_STAT_VALUE: int = 100
#
# --- Log Constants ---
const LOG_FILE_PATH: String = "user://kennel_simulator_log.txt"
#
# --- Customs Inspector Constants ---
var CUSTOMS_BASE_PAYOUT: int = 100
var CUSTOMS_QUOTA: int = 4 # How many packages per shift
var CUSTOMS_CONTRABAND_CHANCE: float = 0.30 # 30% chance for a package to be illegal
#
# Stat Modifiers
var CUSTOMS_ENERGY_COST: float = 8.0
var CUSTOMS_BASE_FOCUS_COST: float = 10.0
#
# Economy & Reputation
var CUSTOMS_REWARD_CASH: int = 15
var CUSTOMS_REWARD_REP: int = 2
var CUSTOMS_PENALTY_FINE: int = 25
var CUSTOMS_PENALTY_REP: int = 5
var CUSTOMS_PENALTY_STRESS: float = 15.0
