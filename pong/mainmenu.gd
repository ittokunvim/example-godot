extends Control


@onready var pong = preload("res://pong.tscn")


func _on_start_button_pressed() -> void:
	Global.goto_scene(pong)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
