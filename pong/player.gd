extends Area2D


# プレイヤーのパドル移動速度。
const MOVE_SPEED := 400.0

# ゲーム開始前やゲームオーバー後の入力を無効にする。
var _active := true

@onready var _screen_size_y: float = get_viewport_rect().size.y
@onready var _player_size_y: float = $ColorRect.size.y
@onready var _initial_position: Vector2 = position

func _process(delta: float) -> void:
	if not _active:
		return
	# 上下入力を1つの値にまとめ、同時押しにも対応する。
	var input := Input.get_action_strength("player_move_down") - Input.get_action_strength("player_move_up")
	position.y = _clamp_position(position.y + input * MOVE_SPEED * delta, _player_size_y)


func _clamp_position(next_y: float, paddle_height: float) -> float:
	return clampf(next_y, 0.0, _screen_size_y - paddle_height)


func reset() -> void:
	# リトライ時にパドルをシーン配置時の位置へ戻す。
	position = _initial_position


func set_active(active: bool) -> void:
	# 親ノードからラウンド中の操作可否を切り替える。
	_active = active
