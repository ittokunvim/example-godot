extends Area2D

const DEFAULT_SPEED = 300.0

var _speed := DEFAULT_SPEED
var direction := Vector2.ZERO

func _ready() -> void:
	direction.x = [1, -1][randi() % 2]
	direction.y = randf_range(0.5, 0.5)
	direction = direction.normalized()


func _process(delta: float) -> void:
	_speed += delta * 2.0
	position += _speed * delta * direction


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("x_walls"):
		direction.x = -direction.x
	elif area.is_in_group("y_walls"):
		direction.y = -direction.y
	elif area.is_in_group("paddles"):
		direction = Vector2(-direction.x, randf() * 2 - 1).normalized()
