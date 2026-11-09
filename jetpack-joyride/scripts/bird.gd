class_name JetpackBird
extends CharacterBody2D

const HORIZONTAL_SPEED := 350.0
const BASE_SCROLL_SPEED := 250.0
const VERTICAL_TRACKING_SPEED := 500.0
const DESPAWN_MARGIN := 64.0

var target: Node2D
var active := false
var horizontal_speed := HORIZONTAL_SPEED

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	sprite.play()


func _physics_process(delta: float) -> void:
	if not active or target == null:
		return

	velocity.x = -horizontal_speed
	velocity.y = move_toward(
		velocity.y,
		target.global_position.y - global_position.y,
		VERTICAL_TRACKING_SPEED * delta,
	)
	move_and_slide()

	if global_position.x < -DESPAWN_MARGIN:
		queue_free()


func setup(target_node: Node2D) -> void:
	target = target_node
	active = true


func set_scroll_speed(scroll_speed: float) -> void:
	horizontal_speed = HORIZONTAL_SPEED + scroll_speed - BASE_SCROLL_SPEED


func set_active(value: bool) -> void:
	active = value
	velocity = Vector2.ZERO
