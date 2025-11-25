class_name WiremockCommonMapper
extends Object

static func map_json_to_mapping(data: Variant) -> Mapping:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	
	var id = data.get("id", "")
	var name = data.get("name", "")
	var request = map_json_to_mapping_request(data.get("request"))
	var response = map_json_to_mapping_response(data.get("response"))
	var priority = data.get("priority", 0)
	var metadata = data.get("metadata", {})
	
	var out = Mapping.new()
	out.id = id
	out.name = name
	out.priority = priority
	out.request = request
	out.response = response
	out.metadata = metadata
	return out

static func map_json_to_mapping_request(data: Variant) -> Mapping.Request:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	
	var method = data.get("method", "")
	var out_method: Mapping.Method
	if method != "":
		out_method = Mapping.Method.get(method, Mapping.Method.ANY)
	
	var url = data.get("url", "")
	var url_path = data.get("urlPath", "")
	var url_path_pattern = data.get("urlPathPattern", "")
	var url_pattern = data.get("urlPattern", "")
	var path_parameters = data.get("pathParameters", {})
	var query_parameters = data.get("queryParameters", {})
	var form_parameters = data.get("formParameters", {})
	var headers = data.get("headers", {})
	var basic_auth_credentials = map_json_to_mapping_basic_auth_credentials(data.get("basicAuthCredentials"))
	var cookies = data.get("cookies", {})
	var body_patterns = data.get("bodyPatterns", null)
	var multipart_patterns = data.get("multipartPatterns", [])
	
	var out_body_patterns: Array[Dictionary]
	if typeof(body_patterns) == TYPE_ARRAY:
		for pattern in body_patterns:
			if typeof(pattern) == TYPE_DICTIONARY:
				out_body_patterns.append(pattern)
	
	var out_multipart_patterns: Array[Dictionary]
	if typeof(multipart_patterns) == TYPE_ARRAY:
		for pattern in multipart_patterns:
			if typeof(pattern) == TYPE_DICTIONARY:
				out_body_patterns.append(pattern)
	
	var out = Mapping.Request.new()
	out.method = out_method
	out.url = url
	out.url_path = url_path
	out.url_pattern = url_pattern
	out.url_path_pattern = url_path_pattern
	out.path_parameters = path_parameters
	out.query_parameters = query_parameters
	out.form_parameters = form_parameters
	out.headers = headers
	out.basic_auth_credentials = basic_auth_credentials
	out.cookies = cookies
	out.body_patterns = out_body_patterns
	out.multipart_patterns = out_multipart_patterns
	return out
	
static func map_json_to_mapping_response(data: Variant) -> Mapping.Response:
	if typeof(data) != TYPE_DICTIONARY:
		return null
		
	var status = data.get("status", 0)
	var body = data.get("body", "")
	var json_body = data.get("jsonBody", {})
	var base64_body = data.get("base64Body", "")
	var body_file_name = data.get("bodyFileName", "")
	var fault = data.get("fault", "")
	var fixed_delay_milliseconds = data.get("fixedDelayMilliseconds", 0.0)
	var proxy_base_url = data.get("proxyBaseUrl", "")
	var proxy_url_prefix_to_remove = data.get("proxyUrlPrefixToRemove", "")
	var additional_proxy_request_headers = data.get("additionalProxyRequestHeaders", {})
	
	var out = Mapping.Response.new()
	out.status = status
	out.body = body
	out.json_body = json_body
	out.base64_body = base64_body
	out.body_file_name = body_file_name
	out.fault = fault
	out.fixed_delay_milliseconds = fixed_delay_milliseconds
	out.proxy_base_url = proxy_base_url
	out.proxy_url_prefix_to_remove = proxy_url_prefix_to_remove
	out.additional_proxy_request_headers = additional_proxy_request_headers
	return out

static func map_json_to_mapping_basic_auth_credentials(data: Variant) -> Mapping.BasicAuthCredentials:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	
	var username = data.get("username", "")
	var password = data.get("password", "")
	
	var out = Mapping.BasicAuthCredentials.new()
	out.username = username
	out.password = password
	return out

static func map_json_from_mapping(mapping: Mapping) -> Variant:
	if mapping == null:
		return null
	var out = {}
	if mapping.id != "":
		out["id"] = mapping.id
	if mapping.name != "":
		out["name"] = mapping.name
	if mapping.priority > 0:
		out["priority"] = mapping.priority
	if mapping.request != null:
		out["request"] = map_json_from_mapping_request(mapping.request)
	if mapping.response != null:
		out["response"] = map_json_from_mapping_response(mapping.response)
	out["metadata"] = mapping.metadata
	return out

static func map_json_from_mapping_request(request: Mapping.Request) -> Variant:
	if request == null:
		return null
	var out = {}
	var method = Mapping.Method.keys()[request.method]
	if method != null:
		out["method"] = method
	if request.url != "":
		out["url"] = request.url
	if request.url_path != "":
		out["urlPath"] = request.url_path
	if request.url_pattern != "":
		out["urlPattern"] = request.url_pattern
	if request.url_path_pattern != "":
		out["urlPathPattern"] = request.url_path_pattern
	return out

static func map_json_from_mapping_response(response: Mapping.Response) -> Variant:
	if response == null:
		return null
	var out = {}
	if response.status > 0:
		out["status"] = response.status
	if response.body != "":
		out["body"] = response.body
	if response.json_body != null:
		out["jsonBody"] = response.json_body
	if response.base64_body != "":
		out["base64Body"] = response.base64_body
	if response.body_file_name != "":
		out["bodyFileName"] = response.body_file_name
	if response.fault != "":
		out["fault"] = response.fault
	if response.fixed_delay_milliseconds > 0:
		out["fixedDelayMilliseconds"] = response.fixed_delay_milliseconds
	if response.proxy_base_url != "":
		out["proxyBaseUrl"] = response.proxy_base_url
	if response.proxy_url_prefix_to_remove != "":
		out["proxyUrlPrefixToRemove"] = response.proxy_url_prefix_to_remove
	if response.additional_proxy_request_headers.size() > 0:
		out["additionalProxyRequestHeaders"] = response.additional_proxy_request_headers
	return out
