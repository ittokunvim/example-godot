class_name BreakoutBall
extends CharacterBody2D


const SPEED := 430.0
const PADDLE_WIDTH := 120.0

var _velocity := Vector2.ZERO

@onready var bounce_sound: AudioStreamPlayer = $BounceSound

func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		return

	var collision := move_and_collide(_velocity * delta)
	if collision == null:
		return

	if not bounce_sound.playing:
		bounce_sound.play()
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


func launch() -> void:
	_velocity = Vector2(0.65, -1.0).normalized() * SPEED


func reset() -> void:
	position = Vector2(get_viewport_rect().size.x / 2.0, 472.0)
	_velocity = Vector2.ZERO


func stop() -> void:
	_velocity = Vector2.ZERO
