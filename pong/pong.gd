extends Node

# 先にこの点数へ到達した側を勝者にする。
const WINNING_SCORE := 5
# 得点後、次のラウンドを始めるまでの待ち時間。
const ROUND_DELAY := 0.75

@onready var _player: Area2D = $Player
@onready var _enemy: Area2D = $Enemy
@onready var _ball: Area2D = $Ball
@onready var _ui: Control = $UI
@onready var _retry: Control = $UI/Retry

# ラウンド中だけ得点イベントを受け付ける。
var _round_active := false
# ゲーム終了後に待機中のカウントダウンを再開させないための状態。
var _game_over := false


func _ready() -> void:
	_start_round()


# リトライ時にスコア、パドル、ボールをすべて初期状態へ戻す。
func new_game() -> void:
	_retry.visible = false
	_game_over = false
	_ui.reset()
	_player.reset()
	_enemy.reset()
	_start_round()


# タイトルに戻るボタンを押したら
func back_to_title() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")


# ボールが画面左端を越えたときの得点処理。
func _on_ball_player_scored() -> void:
	if not _round_active:
		return
	_ui.add_player_score()
	_finish_point(_ui.player_score >= WINNING_SCORE)

func _on_ball_enemy_scored() -> void:
	if not _round_active:
		return
	_ui.add_enemy_score()
	_finish_point(_ui.enemy_score >= WINNING_SCORE)


func _finish_point(game_over: bool) -> void:
	# 得点直後は両パドルとボールを止め、二重入力や二重得点を防ぐ。
	_round_active = false
	_player.set_active(false)
	_enemy.set_active(false)
	_ball.stop()
	if game_over:
		# 最終得点ならゲームオーバー画面を表示する。
		_game_over = true
		_retry.visible = true
		_ui.show_game_over(_ui.player_score > _ui.enemy_score)
		return
	_ui.show_round_message("Point!")
	await get_tree().create_timer(ROUND_DELAY).timeout
	if not _game_over:
		_start_round()


func _start_round() -> void:
	# 開始前は3秒のカウントダウンを表示し、プレイ入力を無効にする。
	_round_active = false
	_player.set_active(false)
	_enemy.set_active(false)
	_ball.stop()
	_ui.show_round_message("Get Ready!")
	await get_tree().create_timer(0.5).timeout
	_ui.show_round_message("3")
	await get_tree().create_timer(0.5).timeout
	_ui.show_round_message("2")
	await get_tree().create_timer(0.5).timeout
	_ui.show_round_message("1")
	await get_tree().create_timer(0.5).timeout
	if _game_over:
		return
	# カウントダウン終了後にだけ、両パドルとボールを動かす。
	_round_active = true
	_player.set_active(true)
	_enemy.set_active(true)
	_ui.show_round_message("Play!")
	_ball.start()
