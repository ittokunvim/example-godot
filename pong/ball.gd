extends Area2D


signal player_scored
signal enemy_scored


var _speed := 400.0
var _direction := Vector2.ZERO


@onready var _initial_position = self.position


func _ready() -> void:
	start()


func _process(delta: float) -> void:
	# ボールを動かす
	_speed += delta * 2.0
	position += _speed * delta * _direction


func _on_area_entered(area: Area2D) -> void:
	# ボールの跳ね返りを実装
	if area.is_in_group("walls"):
		_direction.y = -_direction.y
	elif area.is_in_group("paddles"):
		_direction = Vector2(_direction.x * -1, randf() * 2 - 1).normalized()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if position.x <= 0.0:
		player_scored.emit()
	else:
		enemy_scored.emit()


# ボールの初期設定を行う関数
func start() -> void:
	position = _initial_position
	# xの値を-0.2~0.2の間以外の-1.0~1.0に設定
	_direction.x = randf_range(-1.0, 1.0)
	while abs(_direction.x) <= 0.2:
		_direction.x = randf_range(-1.0, 1.0)
	_direction.y = randf_range(-0.5, 0.5)
	_direction = _direction.normalized()


# ボールの動きを止める関数
func stop() -> void:
	position = _initial_position
	_direction = Vector2.ZERO
