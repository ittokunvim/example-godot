extends Node2D

enum GameState {
	STANDBY,
	PLAYING,
	GAMEOVER,
}

const SCROLL_SPEED := 250.0
const SCROLL_SPEED_INCREMENT := 25.0
const DIFFICULTY_DISTANCE_STEP := 2000.0
const STAR_SCORE := 10
const BIRD_SPAWN_INTERVAL := 5
const BIRD_SCENE := preload("res://scenes/obstacles/bird.tscn")

const STANDBY_MESSAGE := "スペース、クリックを押してスタート"
const PLAYING_MESSAGE := "スタート！"
const GAMEOVER_MESSAGE := "ゲームオーバー"

var state := GameState.STANDBY
var score := 0
var distance_travelled := 0.0
var obstacles_cleared := 0
var next_bird_spawn_at := BIRD_SPAWN_INTERVAL

@onready var plane: CharacterBody2D = $Plane
@onready var birds: Node2D = $Birds
@onready var star_pickup_sound: AudioStreamPlayer = $StarPickupSound
@onready var map_manager: JetpackMapManager = $MapManager
@onready var ui: JetpackUI = $UI


func _ready() -> void:
	plane.crashed.connect(_on_plane_crashed)
	map_manager.star_collected.connect(_on_star_collected)
	map_manager.obstacles_cleared.connect(_on_obstacles_cleared)
	ui.set_score(score)
	_enter_standby()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("fly"):
		return

	match state:
		GameState.STANDBY:
			_start_playing()
		GameState.GAMEOVER:
			_enter_standby()


func _process(delta: float) -> void:
	if state == GameState.GAMEOVER:
		return


	var scroll_speed := _get_scroll_speed()
	var is_playing := state == GameState.PLAYING
	if is_playing:
		distance_travelled += scroll_speed * delta
		
	map_manager.scroll(
		delta,
		scroll_speed,
		_get_difficulty_level(),
		is_playing,
	)


func _enter_standby() -> void:
	state = GameState.STANDBY
	score = 0
	distance_travelled = 0.0
	obstacles_cleared = 0
	next_bird_spawn_at = BIRD_SPAWN_INTERVAL
	ui.set_score(score)
	ui.stop_status_message_timer()
	ui.show_status_message(STANDBY_MESSAGE)
	map_manager.reset()
	for child in birds.get_children():
		child.queue_free()
	plane.reset()


func _start_playing() -> void:
	state = GameState.PLAYING
	ui.show_temporary_status_message(PLAYING_MESSAGE)
	map_manager.start(_get_difficulty_level())
	plane.start_flying()


func _enter_gameover() -> void:
	state = GameState.GAMEOVER
	for child in birds.get_children():
		var bird := child as JetpackBird
		if bird != null:
			bird.set_active(false)
	ui.stop_status_message_timer()
	ui.show_status_message(GAMEOVER_MESSAGE)


func _get_scroll_speed() -> float:
	return SCROLL_SPEED + SCROLL_SPEED_INCREMENT * _get_difficulty_level()


func _get_difficulty_level() -> int:
	return mini(
		int(distance_travelled / DIFFICULTY_DISTANCE_STEP),
		map_manager.get_max_difficulty_level(),
	)

func _on_obstacles_cleared(count: int) -> void:
	obstacles_cleared += count

	while obstacles_cleared >= next_bird_spawn_at:
		_spawn_bird()
		next_bird_spawn_at += BIRD_SPAWN_INTERVAL


func _spawn_bird() -> void:
	var bird := BIRD_SCENE.instantiate() as JetpackBird
	bird.global_position = Vector2(
		get_viewport_rect().size.x + JetpackBird.DESPAWN_MARGIN,
		plane.global_position.y,
	)
	birds.add_child(bird)
	bird.setup(plane)
	bird.set_scroll_speed(_get_scroll_speed())


func _set_birds_scroll_speed(scroll_speed: float) -> void:
	for child in birds.get_children():
		var bird := child as JetpackBird
		if bird != null:
			bird.set_scroll_speed(scroll_speed)


func _on_plane_crashed() -> void:
	if state != GameState.PLAYING:
		return

	_enter_gameover()


func _on_star_collected() -> void:
	if state != GameState.PLAYING:
		return

	score += STAR_SCORE
	ui.set_score(score)
	star_pickup_sound.play()
