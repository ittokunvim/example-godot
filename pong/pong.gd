extends Node

const WINNING_SCORE := 5
const ROUND_DELAY := 0.75

@onready var _player: Area2D = $Player
@onready var _enemy: Area2D = $Enemy
@onready var _ball: Area2D = $Ball
@onready var _ui: Control = $UI
@onready var _retry: Control = $UI/Retry

var _round_active := false
var _game_over := false


func _ready() -> void:
	_start_round()

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
	_round_active = false
	_player.set_active(false)
	_enemy.set_active(false)
	_ball.stop()
	if game_over:
		_game_over = true
		_retry.visible = true
		_ui.show_game_over(_ui.player_score > _ui.enemy_score)
		return
	_ui.show_round_message("Point!")
	await get_tree().create_timer(ROUND_DELAY).timeout
	if not _game_over:
		_start_round()


func _start_round() -> void:
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
	_round_active = true
	_player.set_active(true)
	_enemy.set_active(true)
	_ui.show_round_message("Play!")
	_ball.start()
