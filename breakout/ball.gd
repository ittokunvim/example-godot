class_name BreakoutBall
extends CharacterBody2D


const SPEED := 430.0
const PADDLE_WIDTH := 120.0
const GUIDE_LENGTH := Vector2(150.0, 150.0)
const GUIDE_COLOR := Color8(255, 255, 255, 127)
const GUIDE_WIDTH := 12.0

var _show_launch_guide := true
var _velocity := Vector2.ZERO
var _launch_direction := Vector2(1.0, -1.0).normalized()
var _direction_x := 1

func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		if _show_launch_guide:
			_launch_direction.x += _direction_x * delta
			if _launch_direction.x >= 1.0:
				_direction_x = -1
			elif _launch_direction.x <= -1.0:
				_direction_x = 1
		queue_redraw()
		return

	var collision := move_and_collide(_velocity * delta)
	if collision == null:
		return

	var collider := collision.get_collider()
	if collider is BreakoutBrick:
		collider.take_hit()
		_velocity = _velocity.bounce(collision.get_normal())
	elif collider is CharacterBody2D and collider.is_in_group("paddle"):
		var hit_offset := clampf(
			(global_position.x - collider.global_position.x) / (PADDLE_WIDTH / 2.0),
			-1.0,
			1.0
		)
		_velocity = Vector2(hit_offset * 1.15, -1.0).normalized() * SPEED
		global_position.y = collider.global_position.y - 18.0
	else:
		_velocity = _velocity.bounce(collision.get_normal())


func _draw() -> void:
	if _show_launch_guide:
		draw_line(
			Vector2.ZERO,
			_launch_direction * GUIDE_LENGTH,
			GUIDE_COLOR,
			GUIDE_WIDTH
		)


func launch() -> void:
	_show_launch_guide = false
	_velocity = _launch_direction.normalized() * SPEED
	queue_redraw()


func reset() -> void:
	_show_launch_guide = true
	position = Vector2(get_viewport_rect().size.x / 2.0, 472.0)
	_velocity = Vector2.ZERO


func stop() -> void:
	_show_launch_guide = false
	_velocity = Vector2.ZERO
