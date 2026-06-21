class_name GameConstants
extends Node

# --- Economy Constants ---
const STARTING_CASH: int = 22
const FOOD_COST: int = 5
const WORK_PAYOUT: int = 15
const BASE_RENT: int = 5
#
# --- Dogs Constants ---
const WORK_ENERGY_COST: int = 20
const SLEEP_ENERGY_GAIN: int = 10
const FEED_HUNGER_GAIN: int = 10
const VERY_HUNGRY_TRESHOLD: int = 25
const STARTVING_TRESHOLD: int = 0
const MAX_STAT_VALUE: int = 100
#
# --- Log Constants ---
const LOG_FILE_PATH: String = "user://kennel_simulator_log.txt"
#
# --- Customs Inspector Constants ---
const CUSTOMS_BASE_PAYOUT: int = 100
const CUSTOMS_QUOTA: int = 10 # How many packages per shift
const CUSTOMS_CONTRABAND_CHANCE: float = 0.30 # 30% chance for a package to be illegal
#
# Stat Modifiers
const CUSTOMS_ENERGY_COST: float = 8.0
const CUSTOMS_BASE_FOCUS_COST: float = 10.0
#
# Economy & Reputation
const CUSTOMS_REWARD_CASH: int = 15
const CUSTOMS_REWARD_REP: int = 2
const CUSTOMS_PENALTY_FINE: int = 25
const CUSTOMS_PENALTY_REP: int = 5
const CUSTOMS_PENALTY_STRESS: float = 15.0
