extends Node

const BGM_STREAM := preload("res://art/蒲鉾さちこ - Lazy night Loop.ogg")

@onready var bgm: AudioStreamPlayer = $BGM


func _ready() -> void:
	bgm.stream = BGM_STREAM


func play_bgm() -> void:
	if bgm.playing:
		return
	bgm.play()
