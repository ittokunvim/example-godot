extends Area2D


signal player_scored
signal enemy_scored


# 各ラウンド開始時の速度と、ラリー中に上がる速度の上限。
const INITIAL_SPEED := 450.0
const MAX_SPEED := 800.0

var _speed := INITIAL_SPEED
var _direction := Vector2.ZERO


@onready var _initial_position: Vector2 = position
@onready var _screen_size: Vector2 = get_viewport_rect().size

func _ready() -> void:
	_direction = Vector2.ZERO

func _process(delta: float) -> void:
	if _direction != Vector2.ZERO:
		position += _speed * delta * _direction
		# 壁との衝突を取りこぼしても、ボールが画面外へ抜けないようにする。
		position.y = clamp(position.y, 15.0, _screen_size.y - 15.0)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("walls"):
		# 上下の壁では縦方向だけを反転する。
		_direction.y = -_direction.y
	elif area.is_in_group("paddles"):
		var paddle_visual := area.get_node("ColorRect") as ColorRect
		var paddle_center: float = area.position.y + paddle_visual.size.y / 2.0
		# パドルの中心からどれだけ離れて当たったかを、-1から1に正規化する。
		var hit_position: float = clampf((position.y - paddle_center) / (paddle_visual.size.y / 2.0), -1.0, 1.0)
		var horizontal_direction := 1.0 if area.name == "Player" else -1.0
		# 中心に当たると水平に、端に当たるほど強く上下へ跳ね返す。
		_direction = Vector2(horizontal_direction, hit_position * 1.25).normalized()
		_speed = min(_speed * 1.04, MAX_SPEED)
		# 同じパドルとの衝突を次のフレームで再検出しないよう少し押し出す。
		position.x += horizontal_direction * 2.0
	$BounceSound.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if position.x <= 0.0:
		player_scored.emit()
	else:
		enemy_scored.emit()


# ボールの初期設定を行う関数
func start() -> void:
	position = _initial_position
	_speed = INITIAL_SPEED
	# 横方向がほぼ垂直にならないように、左右へ進む初期方向を選ぶ。
	_direction.x = randf_range(-1.0, 1.0)
	while abs(_direction.x) <= 0.2:
		_direction.x = randf_range(-1.0, 1.0)
	_direction.y = randf_range(-0.5, 0.5)
	_direction = _direction.normalized()


# ボールの動きを止める関数
func stop() -> void:
	position = _initial_position
	_speed = INITIAL_SPEED
	_direction = Vector2.ZERO
