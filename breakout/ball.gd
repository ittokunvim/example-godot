class_name BreakoutBall
extends CharacterBody2D


const SPEED := 430.0

const GUIDE_LENGTH := 150.0
const GUIDE_COLOR := Color8(255, 255, 255, 127)
const GUIDE_WIDTH := 12.0
const AIM_SWEEP_SPEED := 1.0
const INITIAL_DIRECTION := Vector2(1.0, -1.0)
const MARGIN: Vector2 = Vector2(0, 30.0)

@onready var bounce_sound: AudioStreamPlayer = $BounceSound
@onready var paddle: BreakoutPaddle = $"../Paddle"

var _show_aim_sweep := true
var _velocity := Vector2.ZERO
var _launch_direction := INITIAL_DIRECTION.normalized()
var _direction_x := INITIAL_DIRECTION.x


func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		if not _show_aim_sweep:
			return

		position = paddle.position - MARGIN
		_launch_direction.x += _direction_x * AIM_SWEEP_SPEED * delta
		if _launch_direction.x >= 1.0:
			_launch_direction.x = 1.0
			_direction_x = -1.0
		elif _launch_direction.x <= -1.0:
			_launch_direction.x = -1.0
			_direction_x = 1.0

		queue_redraw()
		return

	var collision := move_and_collide(_velocity * delta)
	if collision == null:
		return

	bounce_sound.play()
	var collider := collision.get_collider()
	if collider is BreakoutBrick:
		collider.take_hit()
		_velocity = _velocity.bounce(collision.get_normal())
	elif collider is BreakoutPaddle:
		# パドル中心からのヒット位置に応じて、反射角を変える。
		var hit_offset := clampf(
			(global_position.x - collider.global_position.x) / BreakoutPaddle.HALF_WIDTH,
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
	_velocity = Vector2.ZERO
	queue_redraw()


func stop() -> void:
	_show_aim_sweep = false
	_velocity = Vector2.ZERO
	queue_redraw()
