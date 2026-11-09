class_name JetpackBirdManager
extends Node2D

const BIRD_SCENE := preload("res://scenes/obstacles/bird.tscn")
const BIRD_SPAWN_INTERVAL := 5

var target: Node2D
var obstacles_cleared := 0
var next_bird_spawn_at := BIRD_SPAWN_INTERVAL
var scroll_speed := JetpackBird.BASE_SCROLL_SPEED


func reset(target_node: Node2D) -> void:
	target = target_node
	obstacles_cleared = 0
	next_bird_spawn_at = BIRD_SPAWN_INTERVAL

	for child in get_children():
		child.queue_free()


func register_cleared_obstacles(count: int) -> void:
	obstacles_cleared += count
	while obstacles_cleared >= next_bird_spawn_at:
		_spawn_bird()
		next_bird_spawn_at += BIRD_SPAWN_INTERVAL


func set_scroll_speed(value: float) -> void:
	scroll_speed = value
	for child in get_children():
		var bird := child as JetpackBird
		if bird != null:
			bird.set_scroll_speed(scroll_speed)


func pause() -> void:
	for child in get_children():
		var bird := child as JetpackBird
		if bird != null:
			bird.set_active(false)


func _spawn_bird() -> void:
	if target == null:
		return

	var bird := BIRD_SCENE.instantiate() as JetpackBird
	bird.global_position = Vector2(
		get_viewport_rect().size.x + JetpackBird.DESPAWN_MARGIN,
		target.global_position.y,
	)
	add_child(bird)
	bird.setup(target)
	bird.set_scroll_speed(scroll_speed)
