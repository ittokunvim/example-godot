class_name BreakoutBall
extends CharacterBody2D


const SPEED := 430.0
const PADDLE_WIDTH := 120.0

# 発射待機中に、ボールから伸ばすガイド線の見た目。
const GUIDE_LENGTH := 150.0
const GUIDE_COLOR := Color8(255, 255, 255, 127)
const GUIDE_WIDTH := 12.0

# 照準を左右へ往復させる速さ（方向ベクトルの X 成分/秒）。
const AIM_SWEEP_SPEED := 1.0

# リセット時の初期発射方向。Y を負にすることで必ず上方向へ発射する。
const INITIAL_DIRECTION := Vector2(1.0, -1.0)

var _initial_position := Vector2.ZERO
var _show_aim_sweep := true
var _velocity := Vector2.ZERO

# 発射ガイド用の未正規化ベクトル。
# X 成分だけを変化させ、利用時に normalized() して方向として使う。
var _launch_direction := INITIAL_DIRECTION.normalized()

# 照準の横方向の移動向き。1.0 は右、-1.0 は左。
var _direction_x := INITIAL_DIRECTION.x


func _ready() -> void:
	# シーンで設定した開始位置を、残機を失ったときの復帰位置として保存する。
	_initial_position = position


func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		if not _show_aim_sweep:
			return

		# 発射待機中は照準を左右に往復させる。
		_launch_direction.x += _direction_x * AIM_SWEEP_SPEED * delta
		if _launch_direction.x >= 1.0:
			_launch_direction.x = 1.0
			_direction_x = -1.0
		elif _launch_direction.x <= -1.0:
			_launch_direction.x = -1.0
			_direction_x = 1.0

		# 照準方向が変化したため、ガイド線を再描画する。
		queue_redraw()
		return

	var collision := move_and_collide(_velocity * delta)
	if collision == null:
		return

	var collider := collision.get_collider()
	if collider is BreakoutBrick:
		collider.take_hit()
		_velocity = _velocity.bounce(collision.get_normal())
	elif collider is CharacterBody2D and collider.is_in_group("paddle"):
		# パドル中心からのヒット位置に応じて、反射角を変える。
		var hit_offset := clampf(
			(global_position.x - collider.global_position.x) / (PADDLE_WIDTH / 2.0),
			-1.0,
			1.0
		)
		_velocity = Vector2(hit_offset * 1.15, -1.0).normalized() * SPEED
		global_position.y = collider.global_position.y - 18.0
	else:
		_velocity = _velocity.bounce(collision.get_normal())


func _draw() -> void:
	if _show_aim_sweep:
		# ボールのローカル座標を始点に、現在の発射予定方向を描画する。
		draw_line(
			Vector2.ZERO,
			_launch_direction.normalized() * GUIDE_LENGTH,
			GUIDE_COLOR,
			GUIDE_WIDTH
		)


func launch() -> void:
	# ガイドが示していた方向へボールを発射し、ガイドは非表示にする。
	_show_aim_sweep = false
	_velocity = _launch_direction.normalized() * SPEED
	queue_redraw()


func reset() -> void:
	# 次の発射では初期角度から再び照準を往復させる。
	_show_aim_sweep = true
	_launch_direction = INITIAL_DIRECTION.normalized()
	_direction_x = INITIAL_DIRECTION.x
	position = _initial_position
	_velocity = Vector2.ZERO
	queue_redraw()


func stop() -> void:
	# クリア・ゲームオーバー時は移動と照準ガイドを両方停止する。
	_show_aim_sweep = false
	_velocity = Vector2.ZERO
	queue_redraw()
