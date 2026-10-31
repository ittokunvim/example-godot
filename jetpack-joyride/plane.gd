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
@onready var ground_running_sound: AudioStreamPlayer = $GroundRunningSound


func _ready() -> void:
	start_position = position
	ground_running_sound.finished.connect(_on_ground_running_sound_finished)


func _physics_process(delta: float) -> void:
	if not flying or crashed_state:
		return

	var vertical_acceleration := GRAVITY
	if Input.is_action_pressed("fly"):
		vertical_acceleration -= FLY_THRUST

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
			return

	_update_engine_sounds()

func start_flying() -> void:
	flying = true
	crashed_state = false


func reset() -> void:
	flying = false
	crashed_state = false
	_stop_engine_sounds()
	velocity = Vector2.ZERO
	position = start_position
	rotation = 0.0


func _crash() -> void:
	crashed_state = true
	flying = false
	_stop_engine_sounds()
	velocity = Vector2.ZERO
	rotation = 0.0
	crashed.emit()


func _update_engine_sounds() -> void:
	if is_on_floor():
		rising_sound.stop()
		if not ground_running_sound.playing:
			ground_running_sound.play()
	elif rotation <= 0.2:
		ground_running_sound.stop()
		if not rising_sound.playing:
			rising_sound.play()
	else:
		rising_sound.stop()
		ground_running_sound.stop()


func _stop_engine_sounds() -> void:
	rising_sound.stop()
	ground_running_sound.stop()


func _on_ground_running_sound_finished() -> void:
	if flying and not crashed_state and is_on_floor():
		ground_running_sound.play()
