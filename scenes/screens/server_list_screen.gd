extends Control


func _ready():
	var ctx = Context.new()
	var server_list = ServerListClient.get_server_list(ctx)
	if ctx.is_ok():
		var server_list_json = server_list.map(func(s: MockServer):
			return ServerListCommonMapper.map_json_from_mock_server(s)
		)
		%TestLabel.text = ":D " + JSON.stringify(server_list_json)
	elif ctx.is_error():
		%TestLabel.text = ":("
		
		
