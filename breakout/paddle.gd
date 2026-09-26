class_name BreakoutPaddle
extends CharacterBody2D


const MOVE_SPEED := 620.0
const HALF_WIDTH := 60.0
const HORIZONTAL_MARGIN := 16.0

var _active := true
var _using_keyboard := false
var _initial_position := Vector2.ZERO


func _ready() -> void:
	_initial_position = position


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_using_keyboard = false


func _physics_process(delta: float) -> void:
	if not _active:
		return

	var input := Input.get_axis("move_left", "move_right")

	if input != 0.0:
		_using_keyboard = true

	if _using_keyboard:
		position.x += input * MOVE_SPEED * delta
	else:
		position.x = get_global_mouse_position().x

	position.x = clampf(
		position.x,
		HORIZONTAL_MARGIN + HALF_WIDTH,
		get_viewport_rect().size.x - HORIZONTAL_MARGIN - HALF_WIDTH
	)


func reset() -> void:
	position = _initial_position
	_using_keyboard = false


func set_active(active: bool) -> void:
	_active = active
