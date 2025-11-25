extends Node

var scene_toast = preload("res://scenes/components/toast.tscn")

var display_toast: Toast = null
var pending_toasts: Array[Toast] = []

func show_toast(desc: String, force: bool = false) -> Toast:
	var toast = scene_toast.instantiate() as Toast
	toast.text = desc
	if display_toast == null:
		start_toast(toast)
	else:
		if force:
			display_toast.stop()
			display_toast = null
			start_toast(toast)
		else:
			pending_toasts.append(toast)
	return toast

func _on_display_toast_stopped():
	display_toast = null
	var pending_toast = pending_toasts.pop_front()
	if pending_toast != null:
		start_toast(pending_toast)

func start_toast(toast: Toast) -> void:
	display_toast = toast
	display_toast.tree_exited.connect(_on_display_toast_stopped)
	add_child(display_toast)
