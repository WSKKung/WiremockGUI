# Context is a utility object for storing/retrieving status of an operation
# Any functions that use Context must accept Context as first parameter and call either ok() or error() before returning
# for client to retrieve operation status from the context.
# Client should create new Context using new() for each call to a function and should NEVER send null Context.
class_name Context
extends RefCounted

var has_status: bool = false
var status: Error
var error_message: String = ""
	
func ok() -> void:
	has_status = true
	status = OK
	error_message = ""

func error(e: Error, msg: String) -> void:
	has_status = true
	status = e
	error_message = msg

func is_ok() -> bool:
	return has_status and status == OK

func is_error() -> bool:
	return has_status and status != OK
