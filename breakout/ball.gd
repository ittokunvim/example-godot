class_name BreakoutBall
extends CharacterBody2D


const SPEED := 430.0
const PADDLE_WIDTH := 120.0
const GUIDE_LENGTH := 150.0
const GUIDE_COLOR := Color8(255, 255, 255, 127)
const GUIDE_WIDTH := 12.0
const AIM_SWEEP_SPEED := 1.0
const INITIAL_DIRECTION := Vector2(1.0, -1.0)

var _initial_position := Vector2.ZERO
var _show_aim_sweep := true
var _velocity := Vector2.ZERO
var _launch_direction := INITIAL_DIRECTION.normalized()
var _direction_x := INITIAL_DIRECTION.x

func _ready() -> void:
	_initial_position = position


func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		if not _show_aim_sweep:
			return

		_launch_direction.x += _direction_x * AIM_SWEEP_SPEED * delta
		if _launch_direction.x >= 1.0:
			_launch_direction.x = 1.0
			_direction_x = -1
		elif _launch_direction.x <= -1.0:
			_launch_direction.x = -1.0
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
	if _show_aim_sweep:
		draw_line(
			Vector2.ZERO,
			_launch_direction.normalized() * GUIDE_LENGTH,
			GUIDE_COLOR,
			GUIDE_WIDTH
		)


func launch() -> void:
	_show_aim_sweep = false
	_velocity = _launch_direction.normalized() * SPEED
	queue_redraw()


func reset() -> void:
	_show_aim_sweep = true
	_launch_direction = INITIAL_DIRECTION.normalized()
	_direction_x = INITIAL_DIRECTION.x
	position = _initial_position
	_velocity = Vector2.ZERO


func stop() -> void:
	_show_aim_sweep = false
	_velocity = Vector2.ZERO
