class_name BreakoutBricks
extends Node2D


signal brick_destroyed

const BRICK_SIZE := Vector2(80.0, 24.0)
const BRICK_GAP := 8.0
const BRICK_ORIGIN := Vector2(40.0, 100.0)
const BRICK_COLORS := [
	Color("#ff5d73"), Color("#ff9f43"), Color("#ffe66d"),
	Color("#52d273"), Color("#4dabf7"), Color("#b197fc")
]
const COLUMNS := 10

var remaining := 0


func reset() -> void:
	for brick in get_children():
		brick.queue_free()

	remaining = 0
	for row in BRICK_COLORS.size():
		for column in COLUMNS:
			var brick := BreakoutBrick.new()
			brick.position = BRICK_ORIGIN + Vector2(
				BRICK_SIZE.x / 2.0 + column * (BRICK_SIZE.x + BRICK_GAP),
				BRICK_SIZE.y / 2.0 + row * (BRICK_SIZE.y + BRICK_GAP)
			)
			brick.set_color(BRICK_COLORS[row])
			brick.destroyed.connect(_on_brick_destroyed)
			add_child(brick)
			remaining += 1


func _on_brick_destroyed() -> void:
	remaining -= 1
	brick_destroyed.emit()
