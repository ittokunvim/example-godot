extends Sprite2D

var _image_width: float


func _ready() -> void:
	if texture == null:
		push_error("Background texture is not assigned.")
		set_process(false)
		return

	_image_width = texture.get_width()

	# 背景画像の幅を取得し、同じ画像を右側に1枚追加する。
	var next_background := Sprite2D.new()
	next_background.texture = texture
	next_background.centered = centered
	next_background.position.x = _image_width
	add_child(next_background)


func _process(delta: float) -> void:
	# 背景を左へ移動する。

	position.x -= Global.SPEED * delta

	# 1枚分移動したら元の位置へ戻して、背景を繰り返す。
	if position.x <= -_image_width:
		position.x += _image_width
