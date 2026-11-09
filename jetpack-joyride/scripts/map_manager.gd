class_name JetpackMapManager
extends Node2D

signal star_collected
signal obstacles_cleared(count: int)

const MAP_WIDTH := 960.0
const ACTIVE_MAP_COUNT := 2

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

var active_maps: Array[Node2D] = []
var should_spawn_map_zero := true


func reset() -> void:
	_create_maps([0, 0])


func start(difficulty_level: int) -> void:
	should_spawn_map_zero = false
	_create_maps([0, _get_next_map_index(difficulty_level)])


func scroll(
	delta: float,
	scroll_speed: float,
	difficulty_level: int,
	is_playing: bool,
) -> void:
	for map_index in active_maps.size():
		var map_instance := active_maps[map_index]
		map_instance.position.x -= scroll_speed * delta

		if map_instance.position.x <= -MAP_WIDTH:
			_replace_map(
				map_index,
				map_instance.position.x + MAP_WIDTH * ACTIVE_MAP_COUNT,
				difficulty_level,
				is_playing,
			)


func get_max_difficulty_level() -> int:
	return MAP_INDICES_BY_DIFFICULTY.size() - 1


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
	active_maps.append(map_instance)
	_connect_stars(map_instance)


func _replace_map(
	map_index: int,
	map_position_x: float,
	difficulty_level: int,
	is_playing: bool,
) -> void:
	var old_map := active_maps[map_index]
	obstacles_cleared.emit(_count_obstacles(old_map))
	old_map.queue_free()

	var next_map := MAP_SCENES[
		_get_next_map_index(difficulty_level, is_playing)
	].instantiate() as Node2D
	next_map.position.x = map_position_x
	add_child(next_map)
	active_maps[map_index] = next_map
	_connect_stars(next_map)


func _get_next_map_index(difficulty_level: int, is_playing := true) -> int:
	if not is_playing:
		return 0

	if should_spawn_map_zero:
		should_spawn_map_zero = false
		return 0

	should_spawn_map_zero = true
	var map_indices: Array = MAP_INDICES_BY_DIFFICULTY[difficulty_level]
	return int(map_indices.pick_random())


func _connect_stars(map_instance: Node2D) -> void:
	for child in map_instance.get_children():
		if child is JetpackStar:
			child.collected.connect(star_collected.emit)


func _count_obstacles(map_instance: Node2D) -> int:
	var obstacle_count := 0
	for child in map_instance.get_children():
		if child.is_in_group("obstacle"):
			obstacle_count += 1
	return obstacle_count
