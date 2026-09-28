extends Node2D


const MAP_SCENES: Array[PackedScene] = [
	preload("res://map_0.tscn"),
	preload("res://map_1.tscn"),
]


func _ready() -> void:
	var map_instance = MAP_SCENES[0].instantiate()
	add_child(map_instance)
