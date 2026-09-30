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
var next_map_index := 0

@onready var plane: CharacterBody2D = $Plane


func _ready() -> void:
	_create_maps()
	plane.crashed.connect(_on_plane_crashed)
	_enter_standby()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("fly"):
		return

	match state:
		GameState.STANDBY:
			_start_playing()
		GameState.PLAYING:
			pass
		GameState.GAMEOVER:
			_enter_standby()


func _process(delta: float) -> void:
	if state == GameState.GAMEOVER:
		return

	_scroll_maps(delta)


func _create_maps() -> void:
	for slot in 2:
		_add_map(slot * MAP_WIDTH)


func _add_map(map_position_x: float) -> void:
	var map_instance := MAP_SCENES[next_map_index].instantiate() as Node2D
	next_map_index = (next_map_index + 1) % MAP_SCENES.size()
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
	_reset_maps()
	plane.reset()


func _start_playing() -> void:
	state = GameState.PLAYING
	plane.start_flying()


func _on_plane_crashed() -> void:
	if state != GameState.PLAYING:
		return

	state = GameState.GAMEOVER


func _reset_maps() -> void:
	for index in active_maps.size():
		active_maps[index].position.x = index * MAP_WIDTH
