extends Node

# ボールが外に出たら
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# スコアを加算する
	if $Ball.position.x < 0.0:
		$UI/ScoreLabel1.text = str(int($UI/ScoreLabel1.text) + 1)
	else:
		$UI/ScoreLabel2.text = str(int($UI/ScoreLabel2.text) + 1)

	# ボールを初期位置に戻す
	$Ball.start()
