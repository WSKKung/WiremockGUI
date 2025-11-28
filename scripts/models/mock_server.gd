class_name MockServer
extends RefCounted

var id: String
var name: String
var url: String

func duplicate() -> MockServer:
	var clone = MockServer.new()
	clone.id = id
	clone.name = name
	clone.url = url
	return clone
