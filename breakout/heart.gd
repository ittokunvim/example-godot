class_name BreakoutHeart
extends TextureRect


const MAX_LIVES := 3
const HEART_TEXTURE := preload("res://assets/heart.png")
const HEART_SIZE := Vector2(32.0, 32.0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.texture = HEART_TEXTURE
	self.custom_minimum_size = HEART_SIZE
	self.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	self.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


# ハートを1つ失った状態にする（非表示にする）
func lose() -> void:
	visible = false

# ゲームリスタート時にハートを表示状態へ戻す
func restore() -> void:
	visible = true
