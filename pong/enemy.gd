extends Area2D

const MOVE_SPEED = 150

var _ball: Node2D

@onready var _screen_size_y := get_viewport_rect().size.y
@onready var _enemy_size_y = $ColorRect.size.y


func _ready() -> void:
	_ball = get_node("../Ball")


func _process(delta: float) -> void:
	# ボールの位置に応じて敵を動かす
	var direction_y = 1.0 if position.y + _enemy_size_y / 2.0 < _ball.position.y else -1.0
	position.y = clamp(position.y + direction_y * MOVE_SPEED * delta, 0, _screen_size_y - _enemy_size_y)
