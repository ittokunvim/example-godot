extends Node

const BGM_STREAM := preload("res://assets/audio/music/田中芳典-いつもの居酒屋.ogg")
const SELECTION_STREAM := preload("res://assets/audio/sfx/効果音ラボ-ボタン決定音.ogg")

const BGM_DB := -4.0
# 決定音を同時に重ねて鳴らせる数
const SELECTION_POLYPHONY := 4

@onready var bgm: AudioStreamPlayer = $BGM
@onready var selection_sound: AudioStreamPlayer = $SelectionSound


func _ready() -> void:
	bgm.stream = BGM_STREAM
	bgm.volume_db = BGM_DB
	selection_sound.stream = SELECTION_STREAM
	selection_sound.max_polyphony = SELECTION_POLYPHONY


# BGM を流す。すでに流れていれば、最初からやり直さずにそのまま続ける
func play_bgm() -> void:
	if bgm.playing:
		return
	bgm.play()


# 決定音を鳴らす。前の音が鳴っていても重ねて鳴らす
func play_selection_sound() -> void:
	selection_sound.play()
