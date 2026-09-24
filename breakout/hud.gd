class_name BreakoutHUD
extends Control


@onready var _score_label: Label = $Score
@onready var _description: Label = $Description
@onready var _overlay: PanelContainer = $Overlay
@onready var _message_label: Label = $Overlay/Message
@onready var _hearts_container: HBoxContainer = $Hearts

var _hearts: Array[BreakoutHeart] = []


func setup_hearts(lives: int) -> void:
	for heart in _hearts_container.get_children():
		heart.queue_free()
	_hearts.clear()

	for index in lives:
		var heart := BreakoutHeart.new()
		_hearts_container.add_child(heart)
		_hearts.append(heart)


func update_score(score: int) -> void:
	_score_label.text = "スコア  %04d" % score


func set_description(message: String) -> void:
	_description.text = message


func lose_heart(lives_remaining: int) -> void:
	if lives_remaining >= 0:
		_hearts[lives_remaining].lose()


func restore_hearts() -> void:
	for heart in _hearts:
		heart.restore()


func show_overlay(message: String) -> void:
	_message_label.text = message
	_overlay.show()


func hide_overlay() -> void:
	_overlay.hide()
