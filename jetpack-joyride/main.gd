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

const STANDBY_MESSAGE := "スペース、クリックを押してスタート"
const PLAYING_MESSAGE := "スタート！"
const GAMEOVER_MESSAGE := "ゲームオーバー"

var state := GameState.STANDBY
var score := 0
var distance_travelled := 0.0

@onready var plane: CharacterBody2D = $Plane
@onready var bird_manager: JetpackBirdManager = $BirdManager
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
	bird_manager.set_scroll_speed(scroll_speed)


func _enter_standby() -> void:
	state = GameState.STANDBY
	score = 0
	distance_travelled = 0.0
	ui.set_score(score)
	ui.stop_status_message_timer()
	ui.show_status_message(STANDBY_MESSAGE)
	map_manager.reset()
	bird_manager.reset(plane)
	plane.reset()


func _start_playing() -> void:
	state = GameState.PLAYING
	ui.show_temporary_status_message(PLAYING_MESSAGE)
	map_manager.start(_get_difficulty_level())
	plane.start_flying()


func _enter_gameover() -> void:
	state = GameState.GAMEOVER
	bird_manager.pause()
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
	bird_manager.register_cleared_obstacles(count)


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
