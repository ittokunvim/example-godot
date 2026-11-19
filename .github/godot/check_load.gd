extends SceneTree
# CI 用：プロジェクト内のスクリプトとシーンをすべて読み込み、失敗があれば終了コード 1 で終わる
# Usage: godot --headless --path PROJECT -s res://ci_check_load.gd

const EXTENSIONS := ["gd", "tscn", "tres"]


func _initialize() -> void:
	var self_path: String = get_script().resource_path
	var failed: Array[String] = []
	var checked := 0

	for path in _collect_files("res://"):
		if path == self_path:
			continue
		checked += 1

		var resource := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		# 構文エラーのあるスクリプトは読み込めても、インスタンスを作れない
		if resource == null or (resource is GDScript and not resource.can_instantiate()):
			failed.append(path)

	print("Checked %d files" % checked)
	for path in failed:
		printerr("LOAD FAILED: %s" % path)
	quit(1 if not failed.is_empty() else 0)


func _collect_files(dir_path: String) -> Array[String]:
	var files: Array[String] = []
	for file in DirAccess.get_files_at(dir_path):
		if file.get_extension() in EXTENSIONS:
			files.append(dir_path.path_join(file))
	for dir in DirAccess.get_directories_at(dir_path):
		# .godot などの隠しフォルダは対象にしない
		if not dir.begins_with("."):
			files.append_array(_collect_files(dir_path.path_join(dir)))
	return files
