extends Area2D


const MOVE_SPEED := 400.0

var _active := true

@onready var _screen_size_y: float = get_viewport_rect().size.y
@onready var _player_size_y: float = $ColorRect.size.y
@onready var _initial_position: Vector2 = position

func _process(delta: float) -> void:
	if not _active:
		return
	var input := Input.get_action_strength("player_move_down") - Input.get_action_strength("player_move_up")
	position.y = clamp(position.y + input * MOVE_SPEED * delta, 0, _screen_size_y - _player_size_y)


func reset() -> void:
	position = _initial_position


func set_active(active: bool) -> void:
	_active = active
