class_name BreakoutPaddle
extends CharacterBody2D


const MOVE_SPEED := 620.0
const HALF_WIDTH := 60.0
const HORIZONTAL_MARGIN := 16.0

var _active := false
var _initial_position := Vector2.ZERO


func _ready() -> void:
	_initial_position = position


func _physics_process(delta: float) -> void:
	if not _active:
		return

	var input := Input.get_axis("move_left", "move_right")
	position.x = clampf(
		position.x + input * MOVE_SPEED * delta,
		HORIZONTAL_MARGIN + HALF_WIDTH,
		get_viewport_rect().size.x - HORIZONTAL_MARGIN - HALF_WIDTH
	)


func reset() -> void:
	position = _initial_position


func set_active(active: bool) -> void:
	_active = active
