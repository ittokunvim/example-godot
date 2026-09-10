extends Control


@onready var _player_score_label: Label = $PlayerScore
@onready var _enemy_score_label: Label = $EnemyScore
@onready var _status_label: Label = $Status
@onready var _retry_title: Label = $Retry/Title

var player_score: int = 0
var enemy_score: int = 0


func add_player_score() -> void:
	# スコア表示と得点音を同時に更新する。
	player_score += 1
	_update_score_labels()
	$PointGetSound.play()


func add_enemy_score() -> void:
	# 敵側の得点も同じ表示更新処理で扱う。
	enemy_score += 1
	_update_score_labels()
	$PointGetSound.play()


func reset() -> void:
	# リトライ時に両者のスコアと中央メッセージを初期化する。
	player_score = 0
	enemy_score = 0
	_update_score_labels()
	_status_label.text = "Get Ready!"


func show_round_message(message: String) -> void:
	# カウントダウンやラウンド状態を中央に表示する。
	_status_label.text = message


func show_game_over(player_won: bool) -> void:
	# 最終スコアを比較し、実際の勝者をリトライ画面へ反映する。
	_status_label.text = "Game Over"
	_retry_title.text = "Player Won!" if player_won else "Enemy Won!"


func _update_score_labels() -> void:
	_player_score_label.text = str(player_score)
	_enemy_score_label.text = str(enemy_score)
