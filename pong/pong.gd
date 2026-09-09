extends Node


# プレイヤーに得点が入った
func _on_ball_player_scored() -> void:
	$UI.add_player_score()
	if $UI.player_score >= 5:
		_gameover()
	else:
		_reset()

# 的に得点が入ってしまった
func _on_ball_enemy_scored() -> void:
	$UI.add_enemy_score()
	if $UI.enemy_score >= 5:
		_gameover()
	else:
		_reset()


# 得点時
func _reset() -> void:
	$Ball.start()


# ゲームオーバー時
func _gameover() -> void:
	$Ball.stop()
	$Enemy.reset()
	$UI.reset()
