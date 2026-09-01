extends Area2D

const MOVE_SPEED = 400

var _up: String
var _down: String
var _player_size_y: float

@onready var _screen_size_y := get_viewport_rect().size.y

func _ready() -> void:
	var n := String(name).to_lower()
	_up = n + "_move_up"
	_down = n + "_move_down"
	_player_size_y = $ColorRect.size.y

# プレイヤーを移動させる
func _process(delta: float) -> void:
	var input := Input.get_action_strength(_down) - Input.get_action_strength(_up)
	position.y = clamp(position.y + input * MOVE_SPEED * delta, 0, _screen_size_y - _player_size_y)
