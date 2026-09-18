extends Node2D

signal passed

const PIPE_TEXTURE := preload("res://assets/coral-gate.svg")
const GAP_SIZE := 300.0

var scrolling := true
var pipe_size := Vector2(PIPE_TEXTURE.get_size())
var has_passed := false


func setup(gap_center_y: float) -> void:
	_create_pipe("TopPipe", gap_center_y - GAP_SIZE / 2.0, true)
	_create_pipe("BottomPipe", gap_center_y + GAP_SIZE / 2.0, false)

	var score_area := Area2D.new()
	score_area.name = "ScoreArea"
	score_area.position = Vector2(0.0, gap_center_y)
	score_area.collision_layer = 0
	score_area.collision_mask = 2
	var score_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(8.0, GAP_SIZE)
	score_shape.shape = shape
	score_area.add_child(score_shape)
	score_area.body_entered.connect(_on_score_area_body_entered)
	add_child(score_area)


func _process(delta: float) -> void:
	if not scrolling:
		return

	position.x -= Global.SCROLL_SPEED * delta
	if position.x < -pipe_size.x:
		queue_free()


func _create_pipe(pipe_name: String, edge_y: float, flipped: bool) -> void:
	var body := StaticBody2D.new()
	body.name = pipe_name
	body.position = Vector2(
		0.0,
		edge_y + (pipe_size.y / 2.0 if not flipped else -pipe_size.y / 2.0)
	)
	body.collision_layer = 1
	body.collision_mask = 2

	var sprite := Sprite2D.new()
	sprite.texture = PIPE_TEXTURE
	sprite.flip_v = flipped
	body.add_child(sprite)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = pipe_size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


func _on_score_area_body_entered(body: Node2D) -> void:
	if body.name == "Bird" and not has_passed:
		has_passed = true
		passed.emit()


func set_scrolling(value: bool) -> void:
	scrolling = value
