extends Control

var scene_server_list_item = preload("res://scenes/components/server_list_item.tscn")
var scene_server_detail_screen = preload("res://scenes/screens/server_detail_screen.tscn")
var scene_mapping_list_screen = preload("res://scenes/screens/mapping_list_screen.tscn")

var loading: bool = false

@onready var server_list_container: Container = %ServerListContainer
@onready var add_server_button: Button = %AddServerButton

func _ready():
	fetch_server_list()

func set_loading(v: bool) -> void:
	loading = v
	add_server_button.disabled = loading

func fetch_server_list():
	if loading: return
	set_loading(true)
	
	for child in server_list_container.get_children():
		child.queue_free()
	var ctx = Context.new()
	var server_list = ServerListClient.get_server_list(ctx)
	if ctx.is_ok():
		for server in server_list:
			var server_list_item = scene_server_list_item.instantiate() as ServerListItem
			server_list_container.add_child(server_list_item)
			server_list_item.init_from_server(server)
			server_list_item.view_requested.connect(_on_server_list_item_view_requested.bind(server))
			server_list_item.edit_requested.connect(_on_server_list_item_edit_requested.bind(server))
			server_list_item.remove_requested.connect(_on_server_list_item_remove_requested.bind(server))
	elif ctx.is_error():
		ToastManager.show_toast("Failed to load server list data")
	
	set_loading(false)
	
func _on_add_server_button_pressed():
	if loading: return
	var server = MockServer.new()
	server.name = "New Server"
	server.url = "https://www.example.com"
	var screen = scene_server_detail_screen.instantiate() as ServerDetailScreen
	SceneManager.change_scene_to_node(screen)
	screen.call_deferred("init_from_server", server)

func _on_server_list_item_view_requested(server: MockServer):
	if loading: return
	var screen = scene_mapping_list_screen.instantiate()
	WiremockClient.set_base_url(server.url)
	SceneManager.change_scene_to_node(screen)

func _on_server_list_item_edit_requested(server: MockServer):
	if loading: return
	var screen = scene_server_detail_screen.instantiate() as ServerDetailScreen
	SceneManager.change_scene_to_node(screen)
	screen.call_deferred("init_from_server", server)

func _on_server_list_item_remove_requested(server: MockServer):
	if loading: return
	var delete_confirm_dialog = ConfirmationDialog.new()
	add_child(delete_confirm_dialog)
	delete_confirm_dialog.borderless = true
	delete_confirm_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	delete_confirm_dialog.dialog_text = "Do you want to remove server " + server.name + "from your list?"
	delete_confirm_dialog.ok_button_text = "Yes"
	delete_confirm_dialog.cancel_button_text = "No"
	delete_confirm_dialog.exclusive = true
	delete_confirm_dialog.confirmed.connect(func():
		var ctx = Context.new()
		ServerListClient.delete_server(ctx, server.id)
		if ctx.is_ok():
			ToastManager.show_toast("Deleted server " + server.name)
			fetch_server_list()
		else:
			ToastManager.show_toast("Failed to delete server " + server.name)
			
		delete_confirm_dialog.queue_free()
	)
	delete_confirm_dialog.canceled.connect(func():
		delete_confirm_dialog.queue_free()
	)
	delete_confirm_dialog.visible = true
