extends Node2D

const NEXT_GROUND := "NextGround"

var scrolling := true
var image_width: float

@onready var ground: StaticBody2D = $Ground
@onready var ground_sprite: Sprite2D = $Ground/Sprite2D
@onready var ground_collision: CollisionShape2D = $Ground/CollisionShape2D

func _ready() -> void:
	# すでに複製済みなら、もう一度地面を作らない。
	if has_node(NEXT_GROUND):
		return

	if ground_sprite.texture == null:
		push_error("Ground texture is not assigned.")
		set_process(false)
		return

	# 地面画像の幅を取得し、2枚目の地面を右側に配置する。
	image_width = ground_sprite.texture.get_width()
	var next_ground := $Ground.duplicate() as StaticBody2D
	next_ground.name = NEXT_GROUND
	next_ground.set_script(null)
	next_ground.position.x += image_width
	add_child(next_ground)


func _process(delta: float) -> void:
	if not scrolling:
		return

	# 地面と衝突判定をまとめて左へ移動する。
	position.x -= Global.SCROLL_SPEED * delta

	# 1枚分移動したら元の位置へ戻して、地面を繰り返す。
	if position.x <= -image_width:
		position.x += image_width


func get_ground_top_y() -> float:
	# 地面の上のY座標を取得
	var collision_y := ground_collision.global_position.y
	var collision_shape := ground_collision.shape as RectangleShape2D
	return collision_y - collision_shape.size.y / 2.0


func set_scrolling(value: bool) -> void:
	scrolling = value
