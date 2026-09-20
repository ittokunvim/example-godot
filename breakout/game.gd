extends Node2D

const SCREEN_SIZE := Vector2(960.0, 540.0)
const BALL_RADIUS := 9.0
const BALL_SPEED := 430.0
const PADDLE_SIZE := Vector2(120.0, 18.0)
const PADDLE_Y := 500.0
const PADDLE_SPEED := 620.0
const BRICK_SIZE := Vector2(80.0, 24.0)
const BRICK_GAP := 8.0
const BRICK_ORIGIN := Vector2(40.0, 100.0)
const BRICK_COLORS := [
	Color("#ff5d73"), Color("#ff9f43"), Color("#ffe66d"),
	Color("#52d273"), Color("#4dabf7"), Color("#b197fc")
]

var _paddle_x := (SCREEN_SIZE.x - PADDLE_SIZE.x) / 2.0
var _ball_position := Vector2(SCREEN_SIZE.x / 2.0, PADDLE_Y - 28.0)
var _ball_velocity := Vector2(0.65, -1.0).normalized() * BALL_SPEED
var _bricks: Array[Rect2] = []
var _score := 0
var _lives := 3
var _playing := false
var _game_won := false


func _ready() -> void:
	_create_bricks()
	queue_redraw()


func _process(delta: float) -> void:
	if not _playing:
		if Input.is_action_just_pressed("ui_accept"):
			_start_or_restart()
		return

	var input := Input.get_axis("move_left", "move_right")
	_paddle_x = clampf(_paddle_x + input * PADDLE_SPEED * delta, 16.0, SCREEN_SIZE.x - PADDLE_SIZE.x - 16.0)
	_move_ball(delta)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not _playing:
		_start_or_restart()


func _start_or_restart() -> void:
	if _lives <= 0 or _game_won:
		_score = 0
		_lives = 3
		_game_won = false
		_create_bricks()
	_reset_ball()
	_playing = true
	queue_redraw()


func _move_ball(delta: float) -> void:
	var previous_position := _ball_position
	_ball_position += _ball_velocity * delta

	if _ball_position.x - BALL_RADIUS <= 0.0 or _ball_position.x + BALL_RADIUS >= SCREEN_SIZE.x:
		_ball_position.x = clampf(_ball_position.x, BALL_RADIUS, SCREEN_SIZE.x - BALL_RADIUS)
		_ball_velocity.x = -_ball_velocity.x
	if _ball_position.y - BALL_RADIUS <= 0.0:
		_ball_position.y = BALL_RADIUS
		_ball_velocity.y = absf(_ball_velocity.y)

	var paddle := Rect2(Vector2(_paddle_x, PADDLE_Y), PADDLE_SIZE)
	if _ball_velocity.y > 0.0 and paddle.grow(BALL_RADIUS).has_point(_ball_position):
		_ball_position.y = PADDLE_Y - BALL_RADIUS
		var hit_offset := (_ball_position.x - paddle.get_center().x) / (PADDLE_SIZE.x / 2.0)
		_ball_velocity = Vector2(hit_offset * 1.15, -1.0).normalized() * BALL_SPEED

	for index in _bricks.size():
		var brick := _bricks[index]
		if not brick.grow(BALL_RADIUS).has_point(_ball_position):
			continue
		_bricks.remove_at(index)
		_score += 10
		if previous_position.y + BALL_RADIUS <= brick.position.y or previous_position.y - BALL_RADIUS >= brick.end.y:
			_ball_velocity.y = -_ball_velocity.y
		else:
			_ball_velocity.x = -_ball_velocity.x
		if _bricks.is_empty():
			_playing = false
			_game_won = true
		break

	if _ball_position.y - BALL_RADIUS > SCREEN_SIZE.y:
		_lives -= 1
		_reset_ball()
		if _lives <= 0:
			_playing = false


func _reset_ball() -> void:
	_paddle_x = (SCREEN_SIZE.x - PADDLE_SIZE.x) / 2.0
	_ball_position = Vector2(SCREEN_SIZE.x / 2.0, PADDLE_Y - 28.0)
	_ball_velocity = Vector2(0.65, -1.0).normalized() * BALL_SPEED


func _create_bricks() -> void:
	_bricks.clear()
	for row in BRICK_COLORS.size():
		for column in 10:
			var position := BRICK_ORIGIN + Vector2(
				column * (BRICK_SIZE.x + BRICK_GAP),
				row * (BRICK_SIZE.y + BRICK_GAP)
			)
			_bricks.append(Rect2(position, BRICK_SIZE))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN_SIZE), Color("#101827"))
	draw_string(ThemeDB.fallback_font, Vector2(28.0, 48.0), "SCORE  %04d" % _score, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(650.0, 48.0), "LIVES  %d" % _lives, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, Color.WHITE)

	for index in _bricks.size():
		draw_rect(_bricks[index], BRICK_COLORS[index % BRICK_COLORS.size()])

	draw_rect(Rect2(Vector2(_paddle_x, PADDLE_Y), PADDLE_SIZE), Color("#e9ecef"), true, 4.0)
	draw_circle(_ball_position, BALL_RADIUS, Color("#ffffff"))

	if not _playing:
		var message := "PRESS SPACE OR CLICK TO START"
		if _game_won:
			message = "YOU CLEARED THE BOARD! PRESS SPACE TO PLAY AGAIN"
		elif _lives <= 0:
			message = "GAME OVER - PRESS SPACE TO RETRY"
		draw_rect(Rect2(80.0, 350.0, 640.0, 70.0), Color(0.0, 0.0, 0.0, 0.45))
		draw_string(ThemeDB.fallback_font, Vector2(110.0, 394.0), message, HORIZONTAL_ALIGNMENT_CENTER, 580.0, 20, Color.WHITE)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(230.0, 585.0), "MOVE: A / D or LEFT / RIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#aab7cf"))
