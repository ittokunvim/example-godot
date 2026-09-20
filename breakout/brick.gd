class_name BreakoutBrick
extends StaticBody2D


signal destroyed

const SIZE := Vector2(80.0, 24.0)

var _color := Color.WHITE
var polygon: Polygon2D


func _ready() -> void:
	polygon = Polygon2D.new()
	polygon.polygon = PackedVector2Array([
		Vector2(-SIZE.x / 2.0, -SIZE.y / 2.0),
		Vector2(SIZE.x / 2.0, -SIZE.y / 2.0),
		Vector2(SIZE.x / 2.0, SIZE.y / 2.0),
		Vector2(-SIZE.x / 2.0, SIZE.y / 2.0)
	])
	add_child(polygon)

	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = SIZE
	collision_shape.shape = shape
	add_child(collision_shape)
	set_color(_color)


func set_color(color: Color) -> void:
	_color = color
	if is_instance_valid(polygon):
		polygon.color = _color


func take_hit() -> void:
	collision_layer = 0
	destroyed.emit()
	queue_free()
