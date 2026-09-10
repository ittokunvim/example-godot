extends Area2D


# プレイヤーより遅くして、相手が打ち返せる余地を残す。
const MOVE_SPEED := 150.0


var _ball: Area2D
var _active := true


@onready var _initial_position: Vector2 = position
@onready var _screen_size_y: float = get_viewport_rect().size.y
@onready var _enemy_size_y: float = $ColorRect.size.y


func _ready() -> void:
	_ball = get_node("../Ball") as Area2D


func _process(delta: float) -> void:
	if not _active:
		return
	# ボールの上下位置だけを追いかける簡易AI。
	var direction_y := 1.0 if position.y + _enemy_size_y / 2.0 < _ball.position.y else -1.0
	position.y = clamp(position.y + direction_y * MOVE_SPEED * delta, 0, _screen_size_y - _enemy_size_y)


# 初期位置に戻す関数
func reset() -> void:
	# リトライ時に敵パドルを初期位置へ戻す。
	position = _initial_position


func set_active(active: bool) -> void:
	# ゲームオーバー後はAIが動かないようにする。
	_active = active
