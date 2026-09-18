extends Node2D

const PIPE_TEXTURE := preload("res://assets/coral-gate.svg")
const PIPE_PAIR_SCRIPT := preload("res://pipe_pair.gd")

var score := 0
var started := false
var game_over := false

@onready var screen_size_x: float = get_viewport_rect().size.x
@onready var background: Sprite2D = $Background
@onready var bird: CharacterBody2D = $Bird
@onready var pipe_spawner: Timer = $PipeSpawner
@onready var pipes: Node2D = $Pipes
@onready var ground_loop: Node2D = $GroundLoop
@onready var score_label: Label = $UI/Score
@onready var message_label: Label = $UI/Message
@onready var game_over_panel: Control = $UI/GameOver
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var score_sound: AudioStreamPlayer = $ScoreSound
@onready var crash_sound: AudioStreamPlayer = $CrashSound


func _ready() -> void:
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

	var pipe := PIPE_PAIR_SCRIPT.new()
	pipe.position = Vector2(
		screen_size_x + PIPE_TEXTURE.get_width() / 2.0,
		 0.0
	)
	var ground_y = ground_loop.get_ground_top_y()
	var gap_margin := pipe.GAP_SIZE
	pipe.setup(
		randf_range(gap_margin, ground_y - gap_margin)
	)
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
	music_player.stop()
	crash_sound.play()
	message_label.text = "Game Over"
	message_label.visible = true
	game_over_panel.visible = true
	background.set_scrolling(false)
	ground_loop.set_scrolling(false)
	_set_pipes_scrolling(false)


func new_game() -> void:
	for pipe in pipes.get_children():
		pipe.queue_free()
	score = 0
	game_over = false
	started = false
	game_over_panel.visible = false
	music_player.play()
	bird.reset()
	_update_score()
	_show_ready()
	background.set_scrolling(true)
	ground_loop.set_scrolling(true)
	_set_pipes_scrolling(true)


func _show_ready() -> void:
	message_label.text = "Press SPACE or click to flap"
	message_label.visible = true


func _update_score() -> void:
	score_label.text = str(score)


func _set_pipes_scrolling(value: bool) -> void:
	for pipe in pipes.get_children():
		pipe.set_scrolling(value)
