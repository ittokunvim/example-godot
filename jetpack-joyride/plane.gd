extends CharacterBody2D


signal crashed

const GRAVITY := 1500.0
const FLY_VELOCITY := -6000.0
const MAX_FLY_SPEED := -300.0
const MAX_FALL_SPEED := 300.0

var flying := false
var crashed_state := false
var standby_time := 0.0
var start_position := Vector2.ZERO

@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	start_position = position


func _physics_process(delta: float) -> void:
	if crashed_state:
		return

	if Input.is_action_pressed("fly"):
		velocity.y = maxf(velocity.y + FLY_VELOCITY * delta, MAX_FLY_SPEED)
	else:
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	position.x = start_position.x
	move_and_slide()

	rotation = clampf(velocity.y / 1_200.0, -0.42, 0.7)

	if position.y <= 32.0:
		position.y = 31.0

	for index in range(get_slide_collision_count()):
		var get_collision = get_slide_collision(index)

		if get_collision.get_collider() == null:
			continue

		if get_collision.get_collider().is_in_group("rocks"):
			_crash()
			break


func start_flying() -> void:
	flying = true
	crashed_state = false
	collision.disabled = false


func fly() -> void:
	if flying and not crashed_state:
		velocity.y = FLY_VELOCITY


func reset() -> void:
	flying = false
	crashed_state = false
	standby_time = 0.0
	velocity = Vector2.ZERO
	position = start_position
	rotation = 0.0


func _crash() -> void:
	crashed_state = true
	flying = false
	velocity = Vector2.ZERO
	rotation = 0.0
	crashed.emit()
