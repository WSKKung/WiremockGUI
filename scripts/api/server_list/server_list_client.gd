extends Node

const SERVER_LIST_CONFIG_PATH = 'user://servers.json'

var server_dict: Dictionary = {}

func _ready():
	load_server_list()
	
func load_server_list() -> Error:
	server_dict = {}
	
	var server_list_file_access = FileAccess.open(SERVER_LIST_CONFIG_PATH, FileAccess.READ_WRITE)
	if server_list_file_access == null:
		return FileAccess.get_open_error()
	
	var server_list_json = JSON.parse_string(server_list_file_access.get_as_text())
	server_list_file_access.close()
	
	if server_list_json == null:
		return ERR_PARSE_ERROR
	
	if typeof(server_list_json) != TYPE_ARRAY:
		return ERR_PARSE_ERROR
	
	for server_json in server_list_json:
		var server = ServerListCommonMapper.map_json_to_mock_server(server_json)
		if server != null and server.id != "":
			server_dict[server.id] = server
	
	return OK

func save_server_list() -> Error:
	var server_list_file_access = FileAccess.open(SERVER_LIST_CONFIG_PATH, FileAccess.WRITE)
	if server_list_file_access == null:
		return FileAccess.get_open_error()
	
	var server_list_json = server_dict.values().map(ServerListCommonMapper.map_json_from_mock_server)
	server_list_file_access.store_string(JSON.stringify(server_list_json))
	server_list_file_access.close()
	return OK

func get_server_list(ctx: Context) -> Array[MockServer]: 
	var server_list: Array[MockServer] = []
	for server: MockServer in server_dict.values():
		server_list.append(server.duplicate())
	ctx.ok()
	return server_list

func create_server(ctx: Context, server: MockServer) -> MockServer:
	if server == null:
		ctx.error(ERR_INVALID_DATA, "invalid server")
		return null
	
	server.id = Resource.generate_scene_unique_id()
	server_dict[server.id] = server
	
	var save_err = save_server_list()
	if save_err != OK:
		ctx.error(save_err, "cannot save server list to storage")
		return null
	
	ctx.ok()
	return server

func update_server(ctx: Context, server: MockServer) -> void:
	if server == null or server.id == "" or not server_dict.has(server.id):
		ctx.error(ERR_INVALID_DATA, "invalid server")
		return
	
	server_dict[server.id] = server
	
	var save_err = save_server_list()
	if save_err != OK:
		ctx.error(save_err, "cannot save server list to storage")
		return
	
	ctx.ok()

func delete_server(ctx: Context, server_id: String) -> void:
	if server_id == "" or not server_dict.has(server_id):
		ctx.error(ERR_INVALID_DATA, "invalid server id")
		return
	
	server_dict.erase(server_id)
	
	var save_err = save_server_list()
	if save_err != OK:
		ctx.error(save_err, "cannot save server list to storage")
		return
	
	ctx.ok()
