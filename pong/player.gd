extends Area2D

const MOVE_SPEED = 400

@onready var _screen_size_y := get_viewport_rect().size.y
@onready var _player_size_y = $ColorRect.size.y


func _process(delta: float) -> void:
	var input := Input.get_action_strength("player_move_down") - Input.get_action_strength("player_move_up")
	position.y = clamp(position.y + input * MOVE_SPEED * delta, 0, _screen_size_y - _player_size_y)
