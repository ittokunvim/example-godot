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

var state := GameState.STANDBY
var active_maps: Array[Node2D] = []
var should_spawn_map_zero := true

@onready var plane: CharacterBody2D = $Plane


func _ready() -> void:
	plane.crashed.connect(_on_plane_crashed)
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
	_create_maps([0, 0])
	plane.reset()


func _start_playing() -> void:
	state = GameState.PLAYING
	should_spawn_map_zero = false
	_create_maps([0, _get_next_map_index()])
	plane.start_flying()


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

	state = GameState.GAMEOVER
