extends Node


# リトライボタンを押したら
func new_game() -> void:
	$UI/Retry.visible = false
	$Enemy.reset()
	$UI.reset()
	$Ball.start()


# タイトルに戻るボタンを押したら
func back_to_title() -> void:
	# シーンをメインメニューに切り替え
	get_tree().change_scene_to_file("res://mainmenu.tscn")

# プレイヤーに得点が入った
func _on_ball_player_scored() -> void:
	$UI.add_player_score()
	if $UI.player_score >= 5:
		$UI/Retry.visible = true
		$Ball.stop()
	else:
		$Ball.start()


# 的に得点が入ってしまった
func _on_ball_enemy_scored() -> void:
	$UI.add_enemy_score()
	if $UI.enemy_score >= 5:
		$UI/Retry.visible = true
		$Ball.stop()
	else:
		$Ball.start()
