extends Control


func _ready() -> void:
	AudioManager.play_bgm()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://pong.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
