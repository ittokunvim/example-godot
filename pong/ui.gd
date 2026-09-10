extends Control


var player_score: int = 0
var enemy_score: int = 0


func add_player_score() -> void:
	# スコア表示と得点音を同時に更新する。
	player_score += 1
	$PlayerScore.text = str(player_score)
	$PointGetSound.play()


func add_enemy_score() -> void:
	# 敵側の得点も同じ表示更新処理で扱う。
	enemy_score += 1
	$EnemyScore.text = str(enemy_score)
	$PointGetSound.play()


func reset() -> void:
	# リトライ時に両者のスコアと中央メッセージを初期化する。
	player_score = 0
	enemy_score = 0
	$PlayerScore.text = str(player_score)
	$EnemyScore.text = str(enemy_score)
	$Status.text = "Get Ready!"


func show_round_message(message: String) -> void:
	# カウントダウンやラウンド状態を中央に表示する。
	$Status.text = message


func show_game_over(player_won: bool) -> void:
	# 最終スコアを比較し、実際の勝者をリトライ画面へ反映する。
	$Status.text = "Game Over"
	$Retry/Title.text = "Player Won!" if player_won else "Enemy Won!"
