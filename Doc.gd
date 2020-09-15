var Reducer = preload("res://jiber-godot-client/Reducer.gd")

# The one signal this class emits
signal closed(doc_id)

#
var _state = {}
var _doc_id
	

func _init(doc_id):
	_doc_id = doc_id
	
func on_message(message):
	Reducer.apply(_state, message)

func close():
	emit_signal("closed", _doc_id)
