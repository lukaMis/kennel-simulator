extends Node

@onready var dog_manager = $DogManager
@onready var cash_ui = $CashUI
@onready var info_bar = $InfoBar


func _ready() -> void:
	# Main doesn't do anything on boot anymore! DogManager handles itself.
	pass
