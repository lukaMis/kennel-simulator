extends Node

#var dog_pika = preload("res://dogs/dog_pika.tres")
#var dog_ron = preload("res://dogs/dog_ron.tres")
#var dog_rex = preload("res://dogs/dog_rex.tres")
#
#@onready var ui_pika = $HBoxContainer/DogUIPika
#@onready var ui_ron = $HBoxContainer/DogUIRon
#@onready var ui_rex = $HBoxContainer/DogUIRex

@onready var dog_manager = $DogManager
@onready var cash_ui = $CashUI
@onready var info_bar = $InfoBar


func _ready() -> void:
	# Main doesn't do anything on boot anymore! DogManager handles itself.
	pass

func _on_timer_timeout() -> void:
	# Main just tells the manager that a game tick happened.
	dog_manager.process_dog_ticks()
