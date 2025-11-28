extends Control

const PAGE_SIZE = 10
const GROUP_MAPPING_LIST_ITEM = "mapping_list_item"

var scene_mapping_list_item = preload("res://scenes/components/mapping_list_item.tscn")
var scene_mapping_detail_screen = preload("res://scenes/screens/mapping_detail_screen.tscn")

@onready var mapping_container: Container = %MappingContainer
@onready var search_line_edit: LineEdit = %SearchLineEdit
@onready var page_label: Label = %PageLabel
@onready var previous_page_button: Button = %PreviousPageButton
@onready var next_page_button: Button = %NextPageButton
@onready var create_button: Button = %CreateMappingButton
@onready var refresh_button: Button = %RefreshMappingButton
@onready var search_button: Button = %SearchButton

var loading: bool = false

var page: int = 0
var page_item: int = 0
var total_page: int = -1
var total_item: int = -1

var list_mapping_response: ListMappingResponse

func _ready():
	fetch_list_mapping()

## screen actions

func set_loading(v: bool) -> void:
	loading = v
	previous_page_button.disabled = loading
	next_page_button.disabled = loading
	create_button.disabled = loading
	refresh_button.disabled = loading
	search_button.disabled = loading
	search_line_edit.editable = not loading

# fetch mapping list data from mock server
func fetch_list_mapping() -> void:
	if loading: return
	set_loading(true)
	
	var ctx = Context.new()
	list_mapping_response = await WiremockClient.list_mapping(ctx)
	if ctx.is_ok():
		update_mapping_list_display()
	elif ctx.is_error():
		ToastManager.show_toast("Failed to load mapping list data")

	set_loading(false)
	
# update mapping list item display
func update_mapping_list_display() -> void:
	var mappings = get_mapping_list()
	mappings = filter_mapping_list(mappings)
	
	# update total item to filtered size first to paginate filtered result
	set_total_item(mappings.size())
	
	mappings = paginate_mapping_list(mappings)
	set_page_item(mappings.size())
	
	var mapping_item_nodes = get_tree().get_nodes_in_group(GROUP_MAPPING_LIST_ITEM)
	var old_count = mapping_item_nodes.size()
	var new_count = mappings.size()
	
	var index = 0
	if old_count <= new_count:
		# reuse old node
		while index < old_count:
			var old_item = mapping_item_nodes[index] as MappingListItem
			old_item.init_from_mapping(mappings[index])
			old_item.visible = true
			index += 1
		
		# create new node for remaining item
		while index < new_count:
			var new_item = scene_mapping_list_item.instantiate() as MappingListItem
			mapping_container.add_child(new_item)
			new_item.init_from_mapping(mappings[index])
			new_item.visible = true
			new_item.add_to_group(GROUP_MAPPING_LIST_ITEM)
			new_item.edit_requested.connect(_on_mapping_list_item_edit_requested)
			new_item.clone_requested.connect(_on_mapping_list_item_clone_requested)
			new_item.remove_requested.connect(_on_mapping_list_item_remove_requested)
			index += 1
	else:
		# reuse old node
		while index < new_count:
			var old_item = mapping_item_nodes[index] as MappingListItem
			old_item.init_from_mapping(mappings[index])
			old_item.visible = true
			index += 1
		
		# hide remaining old node to reuse later
		while index < old_count:
			var old_item = mapping_item_nodes[index] as MappingListItem
			old_item.reset()
			old_item.visible = false
			index += 1
	
	update_page_display()

# update page number display
func update_page_display():
	var page = get_page()
	var page_item = get_page_item()
	var total_page = get_total_page()
	var total_item = get_total_item()
	var total_page_label: String = "?" if total_page < 0 else str(total_page)
	var total_item_label: String = "?" if total_item < 0 else str(total_item)
	var label: String = str(page+1) + " / " + total_page_label + " ("+ str(page_item) +" from " + total_item_label + " total)"
	page_label.text = label


## getter

# get search text to filter mapping list
func get_search_text() -> String:
	return search_line_edit.text

# get current page of mapping list (starting from 0)
func get_page() -> int:
	return page

# get item count of current page of mapping list
func get_page_item() -> int:
	return page_item
	
# get total item count of mapping list
func get_total_item() -> int:
	return total_item

# get total page of mapping list
func get_total_page() -> int:
	return total_page

# get mapping list
func get_mapping_list() -> Array[Mapping]:
	if list_mapping_response == null:
		return []
	
	return list_mapping_response.mappings

func filter_mapping_list(mappings: Array[Mapping]) -> Array[Mapping]:
	var search = get_search_text()
	if search == "":
		return mappings
	
	return mappings.filter(func(mapping: Mapping) -> bool:
		return mapping.name.to_lower().contains(search.to_lower())
	)

func paginate_mapping_list(mappings: Array[Mapping]) -> Array[Mapping]:
	var page = get_page()
	var total_item = mappings.size()
	var begin = min(page * PAGE_SIZE, total_item)
	var end = min(begin + PAGE_SIZE, total_item)
	return mappings.slice(begin, end) 

func get_mapping_by_id(mapping_id: String) -> Mapping:
	for m in get_mapping_list():
		if m.id == mapping_id:
			return m
	return null

## setter

# set current page number
func set_page(n: int) -> void:
	if n < 0: n = 0
	var total_page = get_total_page()
	if total_page > 0 and n >= total_page: n = total_page - 1
	page = n

# set item count for currnet page
func set_page_item(n: int) -> void:
	if n < 0: n = 0
	if n > PAGE_SIZE: n = PAGE_SIZE
	page_item = n

# set total item count and update total page according to total item
func set_total_item(new_total_item: int) -> void:
	total_item = new_total_item
	total_page = ceil((total_item + 0.5) / PAGE_SIZE)
	
## signal receivers

func _on_search_line_edit_text_submitted(new_text: String) -> void:
	if loading: return
	set_page(0)
	update_mapping_list_display()

func _on_search_button_pressed() -> void:
	if loading: return
	set_page(0)
	update_mapping_list_display()

func _on_previous_page_button_pressed():
	if loading: return
	set_page(get_page() - 1)
	update_mapping_list_display()

func _on_next_page_button_pressed():
	if loading: return
	set_page(get_page() + 1)
	update_mapping_list_display()

func _on_mapping_list_item_edit_requested(mapping_id: String):
	if loading: return
	var mapping = get_mapping_by_id(mapping_id)
	if mapping == null:
		return
	var screen = scene_mapping_detail_screen.instantiate() as MappingDetailScreen
	screen.call_deferred("init_from_mapping", mapping)
	SceneManager.change_scene_to_node(screen)

func _on_mapping_list_item_clone_requested(mapping_id: String):
	if loading: return
	var mapping = get_mapping_by_id(mapping_id)
	if mapping == null:
		return
	var mapping_clone = mapping.duplicate()
	mapping_clone.id = ""
	mapping_clone.name += " Clone"
	var screen = scene_mapping_detail_screen.instantiate() as MappingDetailScreen
	screen.call_deferred("init_from_mapping", mapping_clone)
	SceneManager.change_scene_to_node(screen)
	ToastManager.show_toast("Cloned mapping " + mapping_clone.name)

var delete_mapping_confirm_dialog: ConfirmationDialog = null

func _on_mapping_list_item_remove_requested(mapping_id: String):
	if loading: return
	if delete_mapping_confirm_dialog != null:
		return
	var mapping = get_mapping_by_id(mapping_id)
	if mapping == null:
		return
	
	delete_mapping_confirm_dialog = ConfirmationDialog.new()
	add_child(delete_mapping_confirm_dialog)
	delete_mapping_confirm_dialog.borderless = true
	delete_mapping_confirm_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	delete_mapping_confirm_dialog.dialog_text = "Do you want to delete mapping " + mapping.name + "?"
	delete_mapping_confirm_dialog.ok_button_text = "Yes"
	delete_mapping_confirm_dialog.cancel_button_text = "No"
	delete_mapping_confirm_dialog.exclusive = true
	delete_mapping_confirm_dialog.confirmed.connect(func():
		var ctx = Context.new()
		await WiremockClient.delete_mapping(ctx, mapping_id)
		if ctx.is_ok():
			ToastManager.show_toast("Deleted mapping " + mapping.name)
			fetch_list_mapping()
		else:
			ToastManager.show_toast("Failed to delete mapping " + mapping.name)
			
		delete_mapping_confirm_dialog.queue_free()
		delete_mapping_confirm_dialog = null
	)
	delete_mapping_confirm_dialog.canceled.connect(func():
		delete_mapping_confirm_dialog.queue_free()
		delete_mapping_confirm_dialog = null
	)
	delete_mapping_confirm_dialog.visible = true
	
func _on_create_mapping_button_pressed():
	if loading: return
	var mapping = Mapping.new()
	mapping.id = ""
	mapping.name = "New Mapping"
	mapping.priority = 5
	mapping.request = Mapping.Request.new()
	mapping.request.method = Mapping.Method.ANY
	mapping.request.url = "/example/path"
	mapping.response = Mapping.Response.new()
	mapping.response.status = 200
	mapping.response.json_body = {
		"stub": "test"
	}
	var screen = scene_mapping_detail_screen.instantiate() as MappingDetailScreen
	screen.call_deferred("init_from_mapping", mapping)
	SceneManager.change_scene_to_node(screen)

func _on_refresh_mapping_button_pressed():
	if loading: return
	fetch_list_mapping()

func _on_return_button_pressed():
	SceneManager.change_scene_to_previus()
