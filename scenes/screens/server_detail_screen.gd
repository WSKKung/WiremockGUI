class_name ServerDetailScreen
extends Control

@onready var name_edit: LineEdit = %NameEdit
@onready var url_edit: LineEdit = %URLEdit
@onready var save_button: Button = %SaveButton

var server_id: String

func _ready():
	reset()

func init_from_server(server: MockServer) -> void:
	reset()
	if server == null:
		return
	
	server_id = server.id
	name_edit.text = server.name
	url_edit.text = server.url

func reset():
	server_id = ""
	name_edit.text = ""
	url_edit.text = ""

func _on_return_button_pressed():
	SceneManager.change_scene_to_previus()

func _on_save_button_pressed():
	save_button.disabled = true
	var ctx = Context.new()
	var server = MockServer.new()
	server.id = server_id
	server.name = name_edit.text
	server.url = url_edit.text
	if server_id == "":
		server = ServerListClient.create_server(ctx, server)
	else:
		ServerListClient.update_server(ctx, server)
	
	if ctx.is_ok():
		ToastManager.show_toast("Saved mock server " + server.name)
	elif ctx.is_error():
		ToastManager.show_toast("Failed to save mock server " + server.name)

	save_button.disabled = false
