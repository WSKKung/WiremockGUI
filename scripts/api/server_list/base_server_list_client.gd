class_name BaseServerListClient
extends Node

func get_server_list(ctx: Context) -> Array[MockServer]: 
	return []

func create_server(ctx: Context, server: MockServer) -> MockServer:
	return null

func update_server(ctx: Context, server: MockServer) -> void:
	pass

func delete_server(ctx: Context, server_id: String) -> void:
	pass
