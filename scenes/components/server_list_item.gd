class_name ServerListItem
extends PanelContainer

signal view_requested()
signal edit_requested()
signal remove_requested()

@onready var name_label: Label = %NameLabel
@onready var url_label: Label = %UrlLabel

func _ready():
	reset()

func init_from_server(server: MockServer) -> void:
	reset()
	if server == null:
		return
	name_label.text = server.name
	url_label.text = server.url

func reset():
	name_label.text = ""
	url_label.text = ""

func _on_view_button_pressed():
	view_requested.emit()

func _on_edit_button_pressed():
	edit_requested.emit()

func _on_remove_button_pressed():
	remove_requested.emit()
