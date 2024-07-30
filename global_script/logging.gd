## Used to log messages to the console with pretty messages.
class_name Logging

## Prints a message using push_error and using the standard error output with
## [error] prfix.
static func error(message: String) -> void:
	push_error(message)
	printerr("[ERROR] %s" % [message])

## Prints a message using push_warning and using the standard error output with
## [warning] prefix.
static func warning(message: String) -> void:
	push_warning(message)
	printerr("[WARNING] %s" % [message])

## Prints a message to standard output with [info] prefix
static func info(message: String) -> void:
	print("[INFO] %s" % [message])
