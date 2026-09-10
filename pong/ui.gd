extends Control


var player_score: int = 0
var enemy_score: int = 0


func add_player_score() -> void:
	player_score += 1
	$PlayerScore.text = str(player_score)
	$PointGetSound.play()


func add_enemy_score() -> void:
	enemy_score += 1
	$EnemyScore.text = str(enemy_score)
	$PointGetSound.play()


func reset() -> void:
	player_score = 0
	enemy_score = 0
	$PlayerScore.text = str(player_score)
	$EnemyScore.text = str(enemy_score)
	$Status.text = "Get Ready!"


func show_round_message(message: String) -> void:
	$Status.text = message


func show_game_over(player_won: bool) -> void:
	$Status.text = "Game Over"
	$Retry/Title.text = "Player Won!" if player_won else "Enemy Won!"
