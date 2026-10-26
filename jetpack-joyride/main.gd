extends Node2D

enum GameState {
	STANDBY,
	PLAYING,
	GAMEOVER,
}

const MAP_WIDTH := 960.0
const SCROLL_SPEED := 250.0
const ACTIVE_MAP_COUNT := 2

const MAP_SCENES: Array[PackedScene] = [
	preload("res://map_0.tscn"),
	preload("res://map_1.tscn"),
	preload("res://map_2.tscn"),
	preload("res://map_3.tscn"),
	preload("res://map_4.tscn"),
	preload("res://map_5.tscn"),
	preload("res://map_6.tscn"),
	preload("res://map_7.tscn"),
	preload("res://map_8.tscn"),
	preload("res://map_9.tscn"),
	preload("res://map_10.tscn"),
]

const STATUS_MESSAGE_DURATION := 2.0

const STANDBY_MESSAGE := "スペース、クリックを押してスタート"
const PLAYING_MESSAGE := "スタート！"
const GAMEOVER_MESSAGE := "ゲームオーバー"

var state := GameState.STANDBY
var active_maps: Array[Node2D] = []
var should_spawn_map_zero := true

@onready var plane: CharacterBody2D = $Plane
@onready var status_message: Label = $UI/StatusMessage
@onready var status_message_timer: Timer = $StatusMessageTimer
@onready var crash_sound: AudioStreamPlayer = $CrashSound


func _ready() -> void:
	plane.crashed.connect(_on_plane_crashed)
	status_message_timer.timeout.connect(_hide_status_message)
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


func _scroll_maps(delta: float) -> void:
	for map_index in active_maps.size():
		var map_instance := active_maps[map_index]
		map_instance.position.x -= SCROLL_SPEED * delta

		if map_instance.position.x <= -MAP_WIDTH:
			_replace_map(
				map_index,
				map_instance.position.x + MAP_WIDTH * ACTIVE_MAP_COUNT
			)


func _replace_map(map_index: int, map_position_x: float) -> void:
	var old_map := active_maps[map_index]
	old_map.queue_free()

	var next_map_index := _get_next_map_index()
	var next_map := MAP_SCENES[next_map_index].instantiate() as Node2D
	next_map.position.x = map_position_x

	add_child(next_map)
	move_child(next_map, 0)
	active_maps[map_index] = next_map


func _enter_standby() -> void:
	state = GameState.STANDBY
	crash_sound.stop()
	status_message_timer.stop()
	_show_status_message(STANDBY_MESSAGE)
	_create_maps([0, 0])
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
	return randi_range(1, MAP_SCENES.size() - 1)


func _on_plane_crashed() -> void:
	if state != GameState.PLAYING:
		return

	_enter_gameover()


func _show_status_message(message: String) -> void:
	status_message.text = message
	status_message.show()


func _hide_status_message() -> void:
	status_message.hide()
