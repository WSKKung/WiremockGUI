class_name Mapping
extends RefCounted

var id: StringName
var name: String
var priority: int
var request: Request
var response: Response
var metadata: Dictionary

class Request extends RefCounted:
	var method: Method
	var url: String
	var url_path: String
	var url_pattern: String
	var url_path_pattern: String
	var path_parameters: Dictionary
	var query_parameters: Dictionary
	var form_parameters: Dictionary
	var headers: Dictionary
	var basic_auth_credentials: BasicAuthCredentials
	var cookies: Dictionary
	var body_patterns: Array[Dictionary]
	var multipart_patterns: Array[Dictionary]
	
	func duplicate() -> Request:
		var clone = Request.new()
		clone.method = method
		clone.url = url
		clone.url_path = url_path
		clone.url_pattern = url_pattern
		clone.url_path_pattern = url_path_pattern
		clone.path_parameters = path_parameters.duplicate()
		clone.query_parameters = query_parameters.duplicate()
		clone.form_parameters = form_parameters.duplicate()
		clone.headers = headers.duplicate()
		if basic_auth_credentials != null:
			clone.basic_auth_credentials = basic_auth_credentials.duplicate()
		clone.cookies = cookies.duplicate()
		clone.body_patterns = body_patterns.duplicate()
		clone.multipart_patterns = multipart_patterns.duplicate()
		return clone

enum Method {
	ANY = 0,
	GET = 1,
	POST = 2,
	PUT = 3,
	PATCH = 4,
	DELETE = 5,
	OPTIONS = 6,
	TRACE = 7
}

enum PathMatchType {
	URL = 0,
	URL_PATH = 1,
	URL_PATTERN = 2,
	URL_PATH_PATTERN = 3
}

class BasicAuthCredentials extends RefCounted:
	var username: String
	var password: String
	
	func duplicate() -> BasicAuthCredentials:
		var clone = BasicAuthCredentials.new()
		clone.username = username
		clone.password = password
		return clone

class Response extends RefCounted:
	var status: int
	var headers: Dictionary
	var body: String
	var base64_body: String
	var json_body: Variant
	var body_file_name: String
	var fault: String
	var fixed_delay_milliseconds: float
	var proxy_base_url: String
	var proxy_url_prefix_to_remove: String
	var additional_proxy_request_headers: Dictionary
	
	func duplicate() -> Response:
		var clone = Response.new()
		clone.status = status
		clone.headers = headers.duplicate()
		clone.body = body
		clone.base64_body = base64_body
		if typeof(json_body) == TYPE_ARRAY or (typeof(json_body) == TYPE_OBJECT and (json_body as Object).has_method("duplicate")):
			clone.json_body = json_body.duplicate()
		else:
			clone.json_body = json_body
		clone.body_file_name = body_file_name
		clone.fault = fault
		clone.fixed_delay_milliseconds = fixed_delay_milliseconds
		clone.proxy_base_url = proxy_base_url
		clone.proxy_url_prefix_to_remove = proxy_url_prefix_to_remove
		clone.additional_proxy_request_headers = additional_proxy_request_headers.duplicate()
		return clone
		

enum BodyType {
	TEXT = 0,
	JSON = 1,
	BASE64 = 2,
	FILE = 3
}

func duplicate() -> Mapping:
	var clone = Mapping.new()
	clone.id = id
	clone.name = name
	clone.priority = priority
	clone.metadata = metadata.duplicate()
	clone.request = request.duplicate()
	clone.response = response.duplicate()
	return clone
