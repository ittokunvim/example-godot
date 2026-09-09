extends Control


@export var player_score = 0
@export var enemy_score = 0


func add_player_score() -> void:
	player_score += 1
	$PlayerScore.text = str(player_score)


func add_enemy_score() -> void:
	enemy_score += 1
	$EnemyScore.text = str(enemy_score)


func reset() -> void:
	player_score = 0
	enemy_score = 0
	$PlayerScore.text = str(player_score)
	$EnemyScore.text = str(enemy_score)
