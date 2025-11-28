extends Node

@export var base_url: String

var http_request: HTTPRequest

func _ready():
	# setup http request for sending request to wiremock
	http_request = HTTPRequest.new()
	add_child(http_request)

func set_base_url(url: String) -> void:
	base_url = url

# generic function for sending http request with default JSON request body and response body
func _http_do(ctx: Context, method: HTTPClient.Method, url: String, body: String) -> Variant:
	print("do request: " + url, ", body: ", body)
	http_request.request(url, [], method, body)
	var http_response = await http_request.request_completed
	var result: int = http_response[0]
	var response_code: int = http_response[1]
	var headers: PackedStringArray = http_response[2]
	var response_body: PackedByteArray = http_response[3]
	if result != OK:
		push_error("send http request has error:", result)
		ctx.error(result, "send http request has error")
		return null
	
	var response_body_text = response_body.get_string_from_utf8()
	if response_code >= HTTPClient.RESPONSE_BAD_REQUEST:
		push_error("received http request error code:", response_code, ", body: ", response_body_text)
		ctx.error(FAILED, "received http request error code")
		return null

	print("do result ok: ", response_code, ", body: ", response_body_text)
	
	var response_body_json = JSON.parse_string(response_body_text)
	if response_body_json == null:
		ctx.error(ERR_PARSE_ERROR, "parse response as json failed")
		return null
	
	ctx.ok()
	return response_body_json

# generic function for sending GET http request
func _http_get(ctx: Context, url: String, params: Dictionary) -> Variant:
	var param_count = params.size()
	if param_count > 0:
		url += "?"
		var i = 0
		for k in params:
			url += k + "=" + params[k]
			if i != param_count - 1:
				url += "&"
			i += 1
	return await _http_do(ctx, HTTPClient.METHOD_GET, url, "")

# generic function for sending POST http request
func _http_post(ctx: Context, url: String, body: String) -> Variant:
	return await _http_do(ctx, HTTPClient.METHOD_POST, url, body)

# generic function for sending PUT http request
func _http_put(ctx: Context, url: String, body: String) -> Variant:
	return await _http_do(ctx, HTTPClient.METHOD_PUT, url, body)
	
# generic function for sending PUT http request
func _http_delete(ctx: Context, url: String, body: String) -> Variant:
	return await _http_do(ctx, HTTPClient.METHOD_DELETE, url, body)
	
func get_version() -> String:
	return ""

# get all mappings
func list_mapping(ctx: Context, req: ListMappingRequest = null) -> ListMappingResponse:
	var url = base_url + "/__admin/mappings"
	var params = {}
	if req != null:
		if req.limit != 0:
			params["limit"] = str(req.limit)
		if req.offset != 0:
			params["offset"] = str(req.offset)
	var response_body = await _http_get(ctx, url, params)
	var response = ListMappingResponse.from_json_object(response_body)
	if response == null:
		ctx.error(ERR_PARSE_ERROR, "parse response from json to object failed")
		return null
	
	return response

func get_mapping_detail(ctx: Context, mapping_id: String) -> Mapping:
	return Mapping.new()

func create_mapping(ctx: Context, mapping: Mapping) -> Mapping:
	if mapping == null:
		return
	var url = base_url + "/__admin/mappings"
	var request_body = JSON.stringify(WiremockCommonMapper.map_json_from_mapping(mapping))
	var response_body = await _http_post(ctx, url, request_body)
	if response_body == null:
		return null
	mapping = WiremockCommonMapper.map_json_to_mapping(response_body)
	if mapping == null:
		ctx.error(ERR_PARSE_ERROR, "parse response from json to object failed")
		return null
	return mapping

func update_mapping(ctx: Context, mapping: Mapping) -> Mapping:
	if mapping == null || mapping.id == "":
		return
	var url = base_url + "/__admin/mappings/" + mapping.id
	var request_body = JSON.stringify(WiremockCommonMapper.map_json_from_mapping(mapping))
	var response_body = await _http_put(ctx, url, request_body)
	if response_body == null:
		return null
	mapping = WiremockCommonMapper.map_json_to_mapping(response_body)
	if mapping == null:
		ctx.error(ERR_PARSE_ERROR, "parse response from json to object failed")
		return null
	return mapping

func delete_mapping(ctx: Context, mapping_id: String) -> void:
	if mapping_id == "":
		return
	var url = base_url + "/__admin/mappings/" + mapping_id
	await _http_delete(ctx, url, "")

func save_mappings() -> void:
	return
