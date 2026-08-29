extends Area2D


@export var speed = 400 # プレイヤーの移動速度(pixels/sec).
var screen_size # ゲームの画面サイズ
var player_size # プレイヤーのサイズ


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_size = $ColorRect.size

# プレイヤーを移動させる
func _process(delta: float) -> void:
	# 入力されたキーに対して移動する方向を定義
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("player_down"):
		velocity.y += 1
	if Input.is_action_pressed("player_up"):
		velocity.y -= 1

	# キーが押されたら標準化を行う
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# プレイヤーを動かす
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size - player_size)
