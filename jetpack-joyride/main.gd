extends Node2D

enum GameState {
	STANDBY,
	PLAYING,
	GAMEOVER,
}

const MAP_WIDTH := 960.0
const SCROLL_SPEED := 250.0
const SCROLL_SPEED_INCREMENT := 25.0
const DIFFICULTY_DISTANCE_STEP := 2000.0
const ACTIVE_MAP_COUNT := 2
const STAR_SCORE := 10
const BIRD_SPAWN_INTERVAL := 5
const BIRD_SCENE := preload("res://scenes/obstacles/bird.tscn")

const MAP_INDICES_BY_DIFFICULTY := [
	[1, 2],
	[1, 2, 3, 4],
	[1, 2, 3, 4, 5, 6],
	[1, 2, 3, 4, 5, 6, 7, 8],
	[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
]

const MAP_SCENES: Array[PackedScene] = [
	preload("res://scenes/maps/segment_00.tscn"),
	preload("res://scenes/maps/segment_01.tscn"),
	preload("res://scenes/maps/segment_02.tscn"),
	preload("res://scenes/maps/segment_03.tscn"),
	preload("res://scenes/maps/segment_04.tscn"),
	preload("res://scenes/maps/segment_05.tscn"),
	preload("res://scenes/maps/segment_06.tscn"),
	preload("res://scenes/maps/segment_07.tscn"),
	preload("res://scenes/maps/segment_08.tscn"),
	preload("res://scenes/maps/segment_09.tscn"),
	preload("res://scenes/maps/segment_10.tscn"),
]

const STATUS_MESSAGE_DURATION := 2.0

const STANDBY_MESSAGE := "スペース、クリックを押してスタート"
const PLAYING_MESSAGE := "スタート！"
const GAMEOVER_MESSAGE := "ゲームオーバー"

var state := GameState.STANDBY
var active_maps: Array[Node2D] = []
var should_spawn_map_zero := true
var score := 0
var distance_travelled := 0.0
var obstacles_cleared := 0
var next_bird_spawn_at := BIRD_SPAWN_INTERVAL

@onready var plane: CharacterBody2D = $Plane
@onready var birds: Node2D = $Birds
@onready var status_message: Label = $UI/StatusMessage
@onready var status_message_timer: Timer = $StatusMessageTimer
@onready var score_label: Label = $UI/Score/Number
@onready var star_pickup_sound: AudioStreamPlayer = $StarPickupSound
@onready var crash_sound: AudioStreamPlayer = $CrashSound


func _ready() -> void:
	plane.crashed.connect(_on_plane_crashed)
	status_message_timer.timeout.connect(_hide_status_message)
	_update_score()
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

	_scroll_maps(delta)


func _create_maps(map_indices: Array[int]) -> void:
	for map_instance in active_maps:
		map_instance.queue_free()
	active_maps.clear()

	for slot in map_indices.size():
		_add_map(map_indices[slot], slot * MAP_WIDTH)


func _add_map(map_index: int, map_position_x: float) -> void:
	var map_instance := MAP_SCENES[map_index].instantiate() as Node2D
	map_instance.position.x = map_position_x
	add_child(map_instance)
	move_child(map_instance, 0)
	active_maps.append(map_instance)
	_connect_star(map_instance)


func _scroll_maps(delta: float) -> void:
	var scroll_speed := _get_scroll_speed()
	if state == GameState.PLAYING:
		distance_travelled += scroll_speed * delta

	_set_birds_scroll_speed(scroll_speed)
	for map_index in active_maps.size():
		var map_instance := active_maps[map_index]
		map_instance.position.x -= scroll_speed * delta

		if map_instance.position.x <= -MAP_WIDTH:
			_replace_map(
				map_index,
				map_instance.position.x + MAP_WIDTH * ACTIVE_MAP_COUNT
			)


func _replace_map(map_index: int, map_position_x: float) -> void:
	var old_map := active_maps[map_index]
	_count_cleared_obstacles(old_map)
	old_map.queue_free()

	var next_map_index := _get_next_map_index()
	var next_map := MAP_SCENES[next_map_index].instantiate() as Node2D
	next_map.position.x = map_position_x

	add_child(next_map)
	move_child(next_map, 0)
	active_maps[map_index] = next_map
	_connect_star(next_map)


func _enter_standby() -> void:
	state = GameState.STANDBY
	score = 0
	distance_travelled = 0.0
	obstacles_cleared = 0
	next_bird_spawn_at = BIRD_SPAWN_INTERVAL
	_update_score()
	crash_sound.stop()
	status_message_timer.stop()
	_show_status_message(STANDBY_MESSAGE)
	_create_maps([0, 0])
	for child in birds.get_children():
		var bird := child as JetpackBird
		if bird != null:
			bird.queue_free()
	plane.reset()


func _start_playing() -> void:
	state = GameState.PLAYING
	should_spawn_map_zero = false
	_show_status_message(PLAYING_MESSAGE)
	status_message_timer.start(STATUS_MESSAGE_DURATION)
	_create_maps([0, _get_next_map_index()])
	plane.start_flying()


func _enter_gameover() -> void:
	state = GameState.GAMEOVER
	for child in birds.get_children():
		var bird := child as JetpackBird
		if bird != null:
			bird.set_active(false)
	crash_sound.play()
	status_message_timer.stop()
	_show_status_message(GAMEOVER_MESSAGE)


func _get_next_map_index() -> int:
	if state == GameState.STANDBY:
		return 0
	
	if should_spawn_map_zero:
		should_spawn_map_zero = false
		return 0

	should_spawn_map_zero = true
	var map_indices: Array = MAP_INDICES_BY_DIFFICULTY[_get_difficulty_level()]
	return int(map_indices.pick_random())


func _get_scroll_speed() -> float:
	return SCROLL_SPEED + SCROLL_SPEED_INCREMENT * _get_difficulty_level()


func _get_difficulty_level() -> int:
	return mini(
		int(distance_travelled / DIFFICULTY_DISTANCE_STEP),
		MAP_INDICES_BY_DIFFICULTY.size() - 1,
	)


func _on_plane_crashed() -> void:
	if state != GameState.PLAYING:
		return

	_enter_gameover()


func _connect_star(map_instance: Node2D) -> void:
	for child in map_instance.get_children():
		if child is JetpackStar:
			child.collected.connect(_on_star_collected)


func _count_cleared_obstacles(map_instance: Node2D) -> void:
	for child in map_instance.get_children():
		if child.is_in_group("obstacle"):
			obstacles_cleared += 1

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


func _on_star_collected() -> void:
	if state != GameState.PLAYING:
		return

	score += STAR_SCORE
	_update_score()
	star_pickup_sound.play()


func _show_status_message(message: String) -> void:
	status_message.text = message
	status_message.show()


func _hide_status_message() -> void:
	status_message.hide()


func _update_score() -> void:
	score_label.text = "%08d" % score
