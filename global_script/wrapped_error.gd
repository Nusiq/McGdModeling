## Error class with a message, to be passed around for nice error handling
## and messages for the user. Functions that return errors to be passed upwards
## should return a WrappedError or null if no error occured.
class_name WrappedError

var message: String = ""
var cause: WrappedError = null
var root := true

func _init(error_message: String) -> void:
    self.message = error_message

func wrap(error_message: String) -> WrappedError:
    var wrapped := WrappedError.new(error_message)
    cause = wrapped
    root = false
    return wrapped


## Returns self. Implemented for the future in case we want to add more
## information to the errors while passing them around. The intention of this
## function is to be used when we want to return an error from an inner
## function without adding any additional text information.
func pass_() -> WrappedError:
    return self

func _to_string_non_recursive() -> String:
    var formatted_message := "\n>>> ".join(message.split("\n"))
    if root:
        return formatted_message
    return "[+] %s" % [formatted_message]

func _to_string() -> String:
    if cause == null:
        return _to_string_non_recursive()
    return "%s\n%s" % [_to_string_non_recursive(), cause._to_string()]