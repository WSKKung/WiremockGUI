class_name ListMappingResponse
extends RefCounted

var mappings: Array[Mapping]
var meta: Meta

class Meta extends RefCounted:
	var total: int
	
	static func from_json_object(data: Variant) -> Meta:
		if typeof(data) != TYPE_DICTIONARY:
			push_error("expect json body to be object")
			return null
		var total = data.get("total", 0)
		var out = Meta.new()
		out.total = total
		return out

static func from_json_object(data: Variant) -> ListMappingResponse:
	if typeof(data) != TYPE_DICTIONARY:
		push_error("expect json body to be object")
		return null
	
	var mappings = data.get("mappings", null)
	var meta = data.get("meta", null)
	
	var out_mappings: Array[Mapping]
	if typeof(mappings) == TYPE_ARRAY:
		for i in mappings.size():
			var out_mapping = WiremockCommonMapper.map_json_to_mapping(mappings[i])
			if out_mapping != null:
				out_mappings.append(out_mapping)
	var out_meta: Meta
	if meta != null:
		out_meta = Meta.from_json_object(meta)
	
	var out = ListMappingResponse.new()
	out.mappings = out_mappings
	out.meta = out_meta
	return out
