extends Area2D

var _speed := 300.0
var _direction := Vector2.ZERO

@onready var _initial_position = $".".position

func _ready() -> void:
	start()

func _process(delta: float) -> void:
	_speed += delta * 2.0
	position += _speed * delta * _direction


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("walls"):
		_direction.y = -_direction.y
	elif area.is_in_group("paddles"):
		_direction = Vector2(_direction.x * -1, randf() * 2 - 1).normalized()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	start()


func start() -> void:
	position = _initial_position
	_direction.x = randf_range(-1.0, 1.0)
	_direction.y = randf_range(-0.5, 0.5)
	_direction = _direction.normalized()
