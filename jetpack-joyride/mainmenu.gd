extends Node2D


@onready var overray: PanelContainer = $UI/OverRay


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_credit_button_pressed() -> void:
	if overray.visible:
		overray.hide()
	else:
		overray.show()
