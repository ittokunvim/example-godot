extends Node2D

const NEXT_GROUND := "NextGround"

var _image_width: float

@onready var ground: StaticBody2D = $Ground
@onready var ground_sprite: Sprite2D = $Ground/Sprite2D
@onready var collision_shape: CollisionShape2D = $Ground/CollisionShape2D

func _ready() -> void:
	# すでに複製済みなら、もう一度地面を作らない。
	if has_node(NEXT_GROUND):
		return

	if ground_sprite.texture == null:
		push_error("Ground texture is not assigned.")
		set_process(false)
		return

	# 地面画像の幅を取得し、2枚目の地面を右側に配置する。
	_image_width = ground_sprite.texture.get_width()
	var next_ground := $Ground.duplicate() as StaticBody2D
	next_ground.name = NEXT_GROUND
	next_ground.set_script(null)
	next_ground.position.x += _image_width
	add_child(next_ground)


func _process(delta: float) -> void:
	# 地面と衝突判定をまとめて左へ移動する。

	position.x -= Global.SPEED * delta

	# 1枚分移動したら元の位置へ戻して、地面を繰り返す。
	if position.x <= -_image_width:
		position.x += _image_width


func get_ground_top_y() -> float:
	var shape := collision_shape.shape as RectangleShape2D
	return collision_shape.global_position.y - shape.size.y / 2.0
