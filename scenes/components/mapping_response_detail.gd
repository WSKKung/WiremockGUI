class_name MappingResponseDetail
extends PanelContainer

@onready var tab_page_fixed: Control = %TabContainer/Fixed
@onready var tab_page_proxy: Control = %TabContainer/Proxy

## fixed response
@onready var status_edit: SpinBox = %StatusEdit
@onready var body_type_option: OptionButton = %BodyTypeOption
@onready var format_body_button: Button = %FomatBodyButton
@onready var body_edit: TextEdit = %BodyEdit
@onready var body_error_label: Label = %BodyErrorLabel

## proxy response
@onready var proxy_base_url_edit: LineEdit = %ProxyBaseUrlEdit
@onready var proxy_trim_prefix_edit: LineEdit = %ProxyTrimPrefixEdit

## shared response
@onready var delay_edit: SpinBox = %DelayEdit

const BODY_TYPE_TEXT = 0
const BODY_TYPE_JSON = 1
const BODY_TYPE_BASE64 = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

func init_from_mapping(mapping: Mapping) -> void:
	reset()
	if mapping == null || mapping.response == null:
		return
	
	status_edit.value = mapping.response.status
	if mapping.response.proxy_base_url != "":
		proxy_base_url_edit.text = mapping.response.proxy_base_url
		proxy_trim_prefix_edit.text = mapping.response.proxy_url_prefix_to_remove
		tab_page_proxy.visible = true
	else:
		if mapping.response.json_body != null:
			set_body_type(BODY_TYPE_JSON)
			body_edit.text = JSON.stringify(mapping.response.json_body, "\t")
		elif mapping.response.base64_body != "":
			set_body_type(BODY_TYPE_BASE64)
			body_edit.text = mapping.response.base64_body
		else:
			set_body_type(BODY_TYPE_TEXT)
			body_edit.text = mapping.response.body
		tab_page_fixed.visible = true
	
	delay_edit.value = mapping.response.fixed_delay_milliseconds
	

func reset():
	status_edit.value = 200
	body_type_option.select(Mapping.BodyType.TEXT)
	format_body_button.disabled = true
	body_edit.text = ""
	body_error_label.text = ""
	delay_edit.value = 0
	proxy_base_url_edit.text = ""
	proxy_trim_prefix_edit.text = ""
	
func set_body_type(v: int) -> void:
	body_type_option.select(v)
	format_body_button.disabled = v != BODY_TYPE_JSON

## getters

func get_mapping_body_type() -> int:
	return body_type_option.get_selected_id()

func get_mapping_response_data() -> Mapping.Response:
	var out = Mapping.Response.new()
	# determine mapping response type by current open tab by user
	if tab_page_proxy.visible:
		out.proxy_base_url = proxy_base_url_edit.text
		out.proxy_url_prefix_to_remove = proxy_trim_prefix_edit.text
	else:
		out.status = int(status_edit.value)
		match get_mapping_body_type():
			BODY_TYPE_TEXT:
				out.body = body_edit.text
			BODY_TYPE_JSON:
				out.json_body = JSON.parse_string(body_edit.text)
			BODY_TYPE_BASE64:
				out.base64_body = body_edit.text
		
	out.fixed_delay_milliseconds = int(delay_edit.value)
	return out

## signal receivers

func _on_body_type_option_item_selected(index: int):
	format_body_button.disabled = index != BODY_TYPE_JSON
	body_error_label.text = ""

func _on_fomat_body_button_pressed():
	match get_mapping_body_type():
		BODY_TYPE_JSON:
			var json = JSON.new()
			var result = json.parse(body_edit.text)
			if result != OK:
				body_error_label.text = json.get_error_message()
				return
			var formatted_text = JSON.stringify(json.data, "\t")
			body_edit.text = formatted_text
			body_error_label.text = ""
