extends BaseServerListClient

func get_server_list(ctx: Context) -> Array[MockServer]: 
	if OS.has_feature("web"):
		
		#JavaScriptBridge.eval('''localStorage.setItem("wiremock_servers", '[{"id":"1","name":"test","url":"https://www.example.com"}]')''')
		var data = JavaScriptBridge.eval('localStorage.getItem("wiremock_servers")')
		if typeof(data) != TYPE_STRING:
			ctx.error(ERR_PARSE_ERROR, "receive invalid data type in localstorage")
			return []
		
		var data_json = JSON.parse_string(data)
		if typeof(data_json) != TYPE_ARRAY:
			ctx.error(ERR_PARSE_ERROR, "receive invalid json data in localstorage")
			return []
		
		var out_server_list: Array[MockServer]
		for server in data_json:
			var out_server = ServerListCommonMapper.map_json_to_mock_server(server)
			if out_server != null:
				out_server_list.append(out_server)
		
		ctx.ok()
		return out_server_list
	else:
		ctx.ok()
		return []

func create_server(ctx: Context, server: MockServer) -> MockServer:
	return null

func update_server(ctx: Context, server: MockServer) -> void:
	pass

func delete_server(ctx: Context, server_id: String) -> void:
	pass
