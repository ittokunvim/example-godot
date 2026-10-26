extends Node


@onready var bgm: AudioStreamPlayer = $BGM
@onready var selection_sound: AudioStreamPlayer = $SelectionSound


func _ready() -> void:
	bgm.play()


func play_selection_sound() -> void:
	selection_sound.play()
