extends Node2D


const MAX_LIVES := 3

enum GameState {
	WAITING_TO_LAUNCH,
	PLAYING,
	GAME_OVER,
}

@onready var paddle: BreakoutPaddle = $Paddle
@onready var ball: BreakoutBall = $Ball
@onready var bricks: BreakoutBricks = $Bricks
@onready var hud: BreakoutHUD = $UI/HUD
@onready var game_over_sound: AudioStreamPlayer = $Sounds/GameOver
@onready var game_clear_sound: AudioStreamPlayer = $Sounds/GameClear
@onready var failure_sound: AudioStreamPlayer = $Sounds/Failure

var _state := GameState.WAITING_TO_LAUNCH
var _lives := MAX_LIVES
var _score := 0


func _ready() -> void:
	bricks.reset()
	bricks.brick_destroyed.connect(_on_brick_destroyed)
	hud.setup_hearts(MAX_LIVES)
	hud.update_score(_score)
	hud.set_description("スペースキー、クリックで開始")


func _unhandled_input(event: InputEvent) -> void:
	if _state == GameState.PLAYING:
		return

	if _state == GameState.WAITING_TO_LAUNCH and _is_launch_requested(event):
		_start_game()
	elif _state == GameState.GAME_OVER and _is_launch_requested(event):
		_restart_game()


func _is_launch_requested(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_accept") \
		or event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT


func _start_game() -> void:
	paddle.set_active(true)
	ball.launch()
	_state = GameState.PLAYING
	hud.hide_overlay()
	hud.set_description("A/D、左右矢印で移動")


func _restart_game() -> void:
	_score = 0
	_lives = MAX_LIVES
	bricks.reset()
	ball.reset()
	paddle.reset()
	hud.restore_hearts()
	_prepare_launch()


func _prepare_launch() -> void:
	_state = GameState.WAITING_TO_LAUNCH
	paddle.set_active(true)
	hud.update_score(_score)
	hud.hide_overlay()
	hud.set_description("スペースキー、クリックで開始")


func _on_brick_destroyed() -> void:
	if _state != GameState.PLAYING:
		return

	_score += 10
	hud.update_score(_score)
	if bricks.remaining == 0:
		_finish_game("すべてのブロックを破壊！ スペースキー、クリックで再挑戦", game_clear_sound)


func _on_loss_zone_body_entered(body: Node2D) -> void:
	if body != ball or _state != GameState.PLAYING:
		return

	_lose_life()
	hud.update_score(_score)
	if _lives <= 0:
		_finish_game("ゲームオーバー - スペースキー、クリックでリトライ", game_over_sound)
		return

	ball.reset()
	_state = GameState.WAITING_TO_LAUNCH
	failure_sound.play()


func _finish_game(message: String, sound: AudioStreamPlayer) -> void:
	sound.play()
	_state = GameState.GAME_OVER
	ball.stop()
	paddle.set_active(false)
	hud.show_overlay(message)


# ボールを落とした時にハートを1つ減らす
func _lose_life() -> void:
	_lives -= 1
	hud.lose_heart(_lives)
