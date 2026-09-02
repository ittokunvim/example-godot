extends Node


var current_scene = null


func _ready():
	var root = get_tree().root
	# ルートの最後の子ノードを取得
	current_scene = root.get_child(-1)


func goto_scene(scene):
	# 遅延呼び出し（クラッシュを防ぐため）
	_deferred_goto_scene.call_deferred(scene)


func _deferred_goto_scene(scene):
	# 安全に現在のシーンを削除
	current_scene.free()
	# 現在のシーンをインスタンス化
	current_scene = scene.instantiate()
	# ルートに現在のシーンを子ノードに追加
	get_tree().root.add_child(current_scene)
	# SceneTree.change_scene_to_file()のためのコード
	get_tree().current_scene = current_scene
