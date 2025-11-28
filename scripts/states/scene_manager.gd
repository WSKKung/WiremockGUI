extends Node

var last_open_scene_paths: Array[String] = []

func change_scene_to_node(scene: Node) -> void:
	var old_scene = get_tree().current_scene
	var old_scene_path = old_scene.scene_file_path
	if old_scene_path != "":
		last_open_scene_paths.append(old_scene_path)
	
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	old_scene.queue_free()

func change_scene_to_previus() -> void:
	var scene_path = last_open_scene_paths.pop_back()
	if scene_path == null:
		return
	var scene = load(scene_path).instantiate()
	var old_scene = get_tree().current_scene
	
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	old_scene.queue_free()
