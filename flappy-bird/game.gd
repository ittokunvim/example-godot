extends Node2D

const BIRD_START := Vector2(180.0, 210.0)
const PIPE_START_X := 850.0
const PIPE_INTERVAL := 1.6

var score := 0
var started := false
var game_over := false

@onready var bird: CharacterBody2D = $Bird
@onready var pipe_spawner: Timer = $PipeSpawner
@onready var pipes: Node2D = $Pipes
@onready var score_label: Label = $UI/Score
@onready var message_label: Label = $UI/Message
@onready var game_over_panel: Control = $UI/GameOver
@onready var score_sound: AudioStreamPlayer = $ScoreSound
@onready var crash_sound: AudioStreamPlayer = $CrashSound


func _ready() -> void:
	pipe_spawner.wait_time = PIPE_INTERVAL
	bird.crashed.connect(_on_bird_crashed)
	bird.reset()
	_update_score()
	_show_ready()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		if game_over:
			new_game()
		elif not started:
			_start_game()


func _on_pipe_spawner_timeout() -> void:
	if not started or game_over:
		return

	var pipe := preload("res://pipe_pair.gd").new()
	pipe.position = Vector2(PIPE_START_X, 0.0)
	pipe.setup(randf_range(155.0, 285.0))
	pipe.passed.connect(_on_pipe_passed)
	pipes.add_child(pipe)


func _start_game() -> void:
	started = true
	game_over = false
	message_label.visible = false
	bird.start()
	pipe_spawner.start()


func _on_pipe_passed() -> void:
	if game_over:
		return
	score += 1
	_update_score()
	score_sound.play()


func _on_bird_crashed() -> void:
	if game_over:
		return
	game_over = true
	started = false
	pipe_spawner.stop()
	crash_sound.play()
	message_label.text = "Game Over"
	message_label.visible = true
	game_over_panel.visible = true


func new_game() -> void:
	for pipe in pipes.get_children():
		pipe.queue_free()
	score = 0
	game_over = false
	started = false
	game_over_panel.visible = false
	bird.position = BIRD_START
	bird.reset()
	_update_score()
	_show_ready()


func _show_ready() -> void:
	message_label.text = "Press SPACE or click to flap"
	message_label.visible = true


func _update_score() -> void:
	score_label.text = str(score)
