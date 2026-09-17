extends CharacterBody2D

signal crashed

const GRAVITY := 2750.0
const FLAP_VELOCITY := -800.0
const MAX_FALL_SPEED := 1500.0

var active := false
var dead := false
var start_position: Vector2

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var flap_sound: AudioStreamPlayer = $FlapSound
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var screen_size_y: float = get_viewport_rect().size.y


func _ready() -> void:
	animation.play("flap")
	start_position = position


func _physics_process(delta: float) -> void:
	if dead:
		velocity.y = velocity.y + GRAVITY * delta
		move_and_slide()
		return

	if not active:
		return

	if Input.is_action_just_pressed("flap"):
		velocity.y = FLAP_VELOCITY
		flap_sound.play()

	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	move_and_slide()
	rotation = clampf(velocity.y / 900.0, -0.5, 1.2)

	if get_slide_collision_count() > 0 or position.y < 0.0 or position.y > screen_size_y:
		crash()


func start() -> void:
	active = true
	dead = false
	velocity = Vector2.ZERO
	rotation = 0.0
	animation.play("flap")


func reset() -> void:
	active = false
	dead = false
	velocity = Vector2.ZERO
	position = start_position
	rotation = 0.0
	collision.disabled = false
	animation.play()


func crash() -> void:
	if dead:
		return
	dead = true
	active = false
	velocity = Vector2.ZERO
	collision.disabled = true
	animation.stop()
	crashed.emit()
