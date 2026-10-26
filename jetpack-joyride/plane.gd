extends CharacterBody2D


signal crashed

const GRAVITY := 1500.0
const FLY_THRUST := 6000.0
const MAX_RISE_SPEED := -300.0
const MAX_FALL_SPEED := 300.0

var flying := false
var crashed_state := false
var start_position := Vector2.ZERO

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var rising_sound: AudioStreamPlayer = $RisingSound


func _ready() -> void:
	start_position = position


func _physics_process(delta: float) -> void:
	if not flying or crashed_state:
		return

	var vertical_acceleration := GRAVITY
	var is_rising := Input.is_action_pressed("fly")
	if is_rising:
		vertical_acceleration -= FLY_THRUST

	_update_rising_sound(is_rising)
	velocity.y = clampf(
		velocity.y + vertical_acceleration * delta,
		MAX_RISE_SPEED,
		MAX_FALL_SPEED,
	)
	position.x = start_position.x
	move_and_slide()
	rotation = clampf(velocity.y / 1_200.0, -0.42, 0.7)

	for collision_index in get_slide_collision_count():
		var slide_collision = get_slide_collision(collision_index)
		var collider := slide_collision.get_collider()
		if collider is Node and collider.is_in_group("obstacle"):
			_crash()
			break


func start_flying() -> void:
	flying = true
	crashed_state = false


func reset() -> void:
	flying = false
	crashed_state = false
	rising_sound.stop()
	velocity = Vector2.ZERO
	position = start_position
	rotation = 0.0


func _crash() -> void:
	crashed_state = true
	flying = false
	rising_sound.stop()
	velocity = Vector2.ZERO
	rotation = 0.0
	crashed.emit()


func _update_rising_sound(is_rising: bool) -> void:
	if is_rising:
		if not rising_sound.playing:
			rising_sound.play()
	else:
		rising_sound.stop()
