extends Node

var dog_pika = preload("res://dogs/dog_pika.tres")
var dog_ron = preload("res://dogs/dog_ron.tres")
var dog_rex = preload("res://dogs/dog_rex.tres")

@onready var ui_pika = $HBoxContainer/DogUIPika
@onready var ui_ron = $HBoxContainer/DogUIRon
@onready var ui_rex = $HBoxContainer/DogUIRex

@onready var cash_ui = $CashUI
@onready var info_bar = $InfoBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui_pika.setup_dog(dog_pika)
	ui_ron.setup_dog(dog_ron)
	ui_rex.setup_dog(dog_rex)

func _on_timer_timeout() -> void:
	dog_pika.tick_stats()
	dog_ron.tick_stats()
	dog_rex.tick_stats()

	ui_pika.update_ui()
	ui_ron.update_ui()
	ui_rex.update_ui()

	# Print to the output console to verify it's working
	print(dog_pika.name, " Hunger: ", dog_pika.hunger)
	print(dog_ron.name, " Hunger: ", dog_ron.hunger)
	print(dog_rex.name, " Hunger: ", dog_rex.hunger)
