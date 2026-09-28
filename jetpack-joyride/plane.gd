extends CharacterBody2D


const GRAVITY = 800.0
const MAX_FALL_SPEED := 800.0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animation.play()


func _physics_process(delta: float) -> void:
	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	move_and_slide()
