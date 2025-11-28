class_name MappingRequestDetail
extends Control

signal mapping_name_updated(new_name: String)

@onready var name_edit: LineEdit = %NameEdit
@onready var priority_edit: SpinBox = %PriorityEdit
@onready var method_option: OptionButton = %MethodOption
@onready var path_match_type_option: OptionButton = %PathMatchTypeOption
@onready var path_edit: LineEdit = %PathEdit

var loading: bool = false

const PATH_MATCH_URL = 0
const PATH_MATCH_URL_PATH = 1
const PATH_MATCH_URL_PATTERN = 2
const PATH_MATCH_URL_PATH_PATTERN = 3

func _ready():
	pass

func init_from_mapping(mapping: Mapping) -> void:
	reset()
	if mapping == null:
		return
	
	name_edit.text = mapping.name
	priority_edit.value = mapping.priority
	
	if mapping.request == null:
		return
	
	method_option.select(mapping.request.method)
	
	if mapping.request.url != "":
		path_edit.text = mapping.request.url
		path_match_type_option.select(PATH_MATCH_URL)
	if mapping.request.url_path != "":
		path_edit.text = mapping.request.url_path
		path_match_type_option.select(PATH_MATCH_URL_PATH)
	if mapping.request.url_pattern != "":
		path_edit.text = mapping.request.url_pattern
		path_match_type_option.select(PATH_MATCH_URL_PATTERN)
	if mapping.request.url_path_pattern != "":
		path_edit.text = mapping.request.url_path_pattern
		path_match_type_option.select(PATH_MATCH_URL_PATH_PATTERN)

func reset() -> void:
	name_edit.text = ""
	priority_edit.value = 0
	method_option.select(0)
	path_match_type_option.select(PATH_MATCH_URL)
	path_edit.text = ""

func set_loading(v: bool) -> void:
	loading = v
	name_edit.editable = not loading
	priority_edit.editable = not loading
	method_option.disabled = loading
	path_match_type_option.disabled = loading
	path_edit.editable = not loading

## getter

func get_mapping_name() -> String:
	return name_edit.text

func get_mapping_priority() -> int:
	return int(priority_edit.value)

func get_mapping_request_data() -> Mapping.Request:
	var out = Mapping.Request.new()
	out.method = method_option.get_selected_id()
	var path_match_type = path_match_type_option.get_selected_id()
	match path_match_type:
		PATH_MATCH_URL:
			out.url = path_edit.text
		PATH_MATCH_URL_PATH:
			out.url_path = path_edit.text
		PATH_MATCH_URL_PATTERN:
			out.url_pattern = path_edit.text
		PATH_MATCH_URL_PATH_PATTERN:
			out.url_path_pattern = path_edit.text
	return out

	
## signal receivers

func _on_name_edit_text_changed(new_text: String):
	mapping_name_updated.emit(new_text)
