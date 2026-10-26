class_name JetpackStar
extends Area2D


signal collected

const COLLECTION_HEIGHT := 48.0
const COLLECTION_DURATION := 0.25

var is_collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_collected or not body.is_in_group("player"):
		return

	is_collected = true
	set_deferred("monitoring", false)
	collected.emit()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - COLLECTION_HEIGHT, COLLECTION_DURATION)
	tween.parallel().tween_property(self, "modulate:a", 0.0, COLLECTION_DURATION)
	tween.tween_callback(queue_free)
