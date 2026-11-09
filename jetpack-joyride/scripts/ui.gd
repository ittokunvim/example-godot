class_name JetpackUI
extends CanvasLayer

const STATUS_MESSAGE_DURATION := 2.0

@onready var status_message: Label = $StatusMessage
@onready var status_message_timer: Timer = $StatusMessageTimer
@onready var score_label: Label = $Score/Number


func _ready() -> void:
	status_message_timer.timeout.connect(hide_status_message)


func set_score(score: int) -> void:
	score_label.text = "%08d" % score


func show_status_message(message: String) -> void:
	status_message.text = message
	status_message.show()


func show_temporary_status_message(message: String) -> void:
	show_status_message(message)
	status_message_timer.start(STATUS_MESSAGE_DURATION)


func hide_status_message() -> void:
	status_message.hide()


func stop_status_message_timer() -> void:
	status_message_timer.stop()
