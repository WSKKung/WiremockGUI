class_name MappingDetailScreen
extends Control

var mapping_id: String

@onready var title_lable: Label = %TitleLabel
@onready var mapping_request_detail: MappingRequestDetail = %MappingRequestDetail
@onready var mapping_response_detail: MappingResponseDetail = %MappingResponseDetail
@onready var save_button: Button = %SaveButton

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

func init_from_mapping(mapping: Mapping) -> void:
	reset()
	if mapping == null:
		return
	
	mapping_id = mapping.id
	title_lable.text = "Editing " + mapping.name
	
	mapping_request_detail.init_from_mapping(mapping)
	mapping_response_detail.init_from_mapping(mapping)

func reset() -> void:
	mapping_id = ""
	title_lable.text = "Editing "


## Signal Receivers

func _on_mapping_request_detail_mapping_name_updated(new_name: String):
	title_lable.text = "Editing " + new_name

func _on_save_button_pressed():
	save_button.disabled = true
	var mapping = Mapping.new()
	mapping.id = mapping_id
	mapping.name = mapping_request_detail.get_mapping_name()
	mapping.priority = mapping_request_detail.get_mapping_priority()
	mapping.request = mapping_request_detail.get_mapping_request_data()
	mapping.response = mapping_response_detail.get_mapping_response_data()
	var ctx = Context.new()
	if mapping.id == "":
		await WiremockClient.create_mapping(ctx, mapping)
	else:
		await WiremockClient.update_mapping(ctx, mapping)
	
	if ctx.is_ok():
		ToastManager.show_toast("Saved mapping " + mapping.name)
		init_from_mapping(mapping)
	elif ctx.is_error():
		ToastManager.show_toast("Failed to save mapping " + mapping.name)
	
	save_button.disabled = false

func _on_return_button_pressed():
	SceneManager.change_scene_to_previus()
