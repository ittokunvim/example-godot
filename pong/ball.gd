extends Area2D

const DEFAULT_SPEED = 100.0

var _speed := DEFAULT_SPEED
var direction := Vector2.ZERO

func _ready() -> void:
	direction.x = [1, -1][randi() % 2]
	direction.y = randf_range(0.5, 0.5)
	direction = direction.normalized()


func _process(delta: float) -> void:
	_speed += delta * 2.0
	position += _speed * delta * direction
