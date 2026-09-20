extends Node2D


const BRICK_SIZE := Vector2(80.0, 24.0)
const BRICK_GAP := 8.0
const BRICK_ORIGIN := Vector2(40.0, 100.0)
const BRICK_COLORS := [
	Color("#ff5d73"), Color("#ff9f43"), Color("#ffe66d"),
	Color("#52d273"), Color("#4dabf7"), Color("#b197fc")
]
const MAX_LIVES := 3

@onready var paddle: BreakoutPaddle = $Paddle
@onready var ball: BreakoutBall = $Ball
@onready var bricks: Node2D = $Bricks
@onready var score_label: Label = $UI/HUD/Score
@onready var lives_label: Label = $UI/HUD/Lives
@onready var overlay: PanelContainer = $UI/HUD/Overlay
@onready var message_label: Label = $UI/HUD/Overlay/Message
@onready var hearts_container: HBoxContainer = $UI/HUD/Hearts

var _hearts: Array[BreakoutHeart] = []
var _lives := MAX_LIVES
var _score := 0
var _bricks_remaining := 0
var _playing := false
var _game_won := false


func _ready() -> void:
	_create_bricks()
	_create_hearts()
	_update_hud()
	_show_overlay("スペースキーまたはクリックで開始")


func _unhandled_input(event: InputEvent) -> void:
	if _playing:
		return
	if event.is_action_pressed("ui_accept"):
		_start_or_restart()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start_or_restart()


func _start_or_restart() -> void:
	if _lives <= 0 or _game_won:
		_score = 0
		_lives = 3
		_game_won = false
		_create_bricks()

	paddle.reset()
	paddle.set_active(true)
	ball.reset()
	ball.launch()
	_playing = true
	overlay.hide()
	_update_hud()
	_restore_hearts()


func _create_bricks() -> void:
	for brick in bricks.get_children():
		brick.queue_free()

	_bricks_remaining = 0
	for row in BRICK_COLORS.size():
		for column in 10:
			var brick := BreakoutBrick.new()
			brick.position = BRICK_ORIGIN + Vector2(
				BRICK_SIZE.x / 2.0 + column * (BRICK_SIZE.x + BRICK_GAP),
				BRICK_SIZE.y / 2.0 + row * (BRICK_SIZE.y + BRICK_GAP)
			)
			brick.set_color(BRICK_COLORS[row])
			brick.destroyed.connect(_on_brick_destroyed)
			bricks.add_child(brick)
			_bricks_remaining += 1


func _on_brick_destroyed() -> void:
	if not _playing:
		return

	_score += 10
	_bricks_remaining -= 1
	_update_hud()
	if _bricks_remaining == 0:
		_playing = false
		_game_won = true
		ball.stop()
		paddle.set_active(false)
		_show_overlay("すべてのブロックを破壊！ スペースキーで再挑戦")


func _on_loss_zone_body_entered(body: Node2D) -> void:
	if body != ball or not _playing:
		return

	_lose_life()
	_update_hud()
	ball.reset()
	if _lives <= 0:
		_playing = false
		paddle.set_active(false)
		_show_overlay("ゲームオーバー - スペースキーでリトライ")
		return

	ball.launch()


func _update_hud() -> void:
	score_label.text = "スコア  %04d" % _score


func _show_overlay(message: String) -> void:
	message_label.text = message
	overlay.show()


# ハートをMAX_LIVES分だけ生成する
func _create_hearts() -> void:
	for heart in hearts_container.get_children():
		heart.queue_free()
	_hearts.clear()

	for i in MAX_LIVES:
		var heart := BreakoutHeart.new()
		hearts_container.add_child(heart)
		_hearts.append(heart)


# ボールを落とした時にハートを1つ減らす
func _lose_life() -> void:
	_lives -= 1
	if _lives >= 0:
		_hearts[_lives].lose()


# ゲーム開始・リスタート時にハートを全部戻す
func _restore_hearts() -> void:
	_lives = MAX_LIVES
	for heart in _hearts:
		heart.restore()
