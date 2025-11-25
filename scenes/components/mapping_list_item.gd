class_name MappingListItem
extends PanelContainer

signal edit_requested(mapping_id: String)
signal clone_requested(mapping_id: String)
signal remove_requested(mapping_id: String)

static var method_to_color_map: Dictionary = {
	Mapping.Method.GET: Color.WEB_GREEN,
	Mapping.Method.POST: Color.DODGER_BLUE,
	Mapping.Method.PUT: Color.GOLD,
	Mapping.Method.PATCH: Color.DARK_ORANGE,
	Mapping.Method.DELETE: Color.FIREBRICK,
	Mapping.Method.OPTIONS: Color.BLUE_VIOLET
}

@onready var name_label: Label = %NameLabel
@onready var method_label: Label = %MethodLabel
@onready var path_label: Label = %PathLabel
@onready var priority_label: Label = %PriorityLabel

var mapping_id: String

func _ready():
	reset()

func init_from_mapping(mapping: Mapping) -> void:
	reset()
	if mapping == null:
		return
	mapping_id = mapping.id
	name_label.text = mapping.name
	name_label.self_modulate = Color.WHITE
	
	if mapping.request != null:
		method_label.text = Mapping.Method.find_key(mapping.request.method)
		method_label.self_modulate = method_to_color_map.get(mapping.request.method, Color.WHITE)
		for path in [ 
			mapping.request.url, 
			mapping.request.url_path, 
			mapping.request.url_pattern, 
			mapping.request.url_path_pattern 
		]:
			if path != "":
				path_label.text = path
				path_label.self_modulate = Color.WHITE
	if mapping.priority != 0:
		priority_label.text = str(mapping.priority)
		priority_label.self_modulate = Color.WHITE

func reset() -> void:
	mapping_id = ""
	name_label.text = "(unnamed)"
	name_label.self_modulate = Color.GRAY
	method_label.text = "(any)"
	method_label.self_modulate = Color.GRAY
	path_label.text = "(any)"
	path_label.self_modulate = Color.GRAY
	priority_label.text = "-"
	priority_label.self_modulate = Color.GRAY

## signal receivers

func _on_edit_button_pressed():
	if mapping_id == "":
		return
	edit_requested.emit(mapping_id)

func _on_clone_button_pressed():
	if mapping_id == "":
		return
	clone_requested.emit(mapping_id)

func _on_remove_button_pressed():
	if mapping_id == "":
		return
	remove_requested.emit(mapping_id)
