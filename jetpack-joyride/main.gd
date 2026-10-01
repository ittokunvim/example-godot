extends Node2D

enum GameState {
	STANDBY,
	PLAYING,
	GAMEOVER,
}

const MAP_WIDTH := 960.0
const SCROLL_SPEED := 250.0

const MAP_SCENES: Array[PackedScene] = [
	preload("res://map_0.tscn"),
	preload("res://map_1.tscn"),
]

var state := GameState.STANDBY
var active_maps: Array[Node2D] = []

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
	for map_instance in active_maps:
		map_instance.position.x -= SCROLL_SPEED * delta
		if map_instance.position.x <= -MAP_WIDTH:
			map_instance.position.x += MAP_WIDTH * active_maps.size()


func _enter_standby() -> void:
	state = GameState.STANDBY
	_create_maps([0, 0])
	plane.reset()


func _start_playing() -> void:
	state = GameState.PLAYING
	_create_maps([0, 1])
	plane.start_flying()


func _on_plane_crashed() -> void:
	if state != GameState.PLAYING:
		return

	state = GameState.GAMEOVER
