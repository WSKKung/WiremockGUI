class_name ServerListCommonMapper
extends Node

static func map_json_from_mock_server(server: MockServer) -> Variant:
	var out = {}
	out["id"] = server.id
	out["name"] = server.name
	out["url"] = server.url
	return out

static func map_json_to_mock_server(data: Variant) -> MockServer:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var out = MockServer.new()
	out.id = data.get("id", "")
	out.name = data.get("name", "")
	out.url = data.get("url", "")
	return out
