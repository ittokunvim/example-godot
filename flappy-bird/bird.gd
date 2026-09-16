extends CharacterBody2D

signal crashed

const GRAVITY := 1200.0
const FLAP_VELOCITY := -420.0
const MAX_FALL_SPEED := 700.0

var active := false
var dead := false
var _initial_position: Vector2

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var flap_sound: AudioStreamPlayer = $FlapSound


func _ready() -> void:
	animation.play("flap")
	_initial_position = position


func _physics_process(delta: float) -> void:
	if not active or dead:
		return

	if Input.is_action_just_pressed("flap"):
		velocity.y = FLAP_VELOCITY
		flap_sound.play()

	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	move_and_slide()
	rotation = clampf(velocity.y / 900.0, -0.5, 1.2)

	if get_slide_collision_count() > 0 or position.y < 0.0 or position.y > 370.0:
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
	position = _initial_position
	rotation = 0.0


func crash() -> void:
	if dead:
		return
	dead = true
	active = false
	velocity = Vector2.ZERO
	crashed.emit()
