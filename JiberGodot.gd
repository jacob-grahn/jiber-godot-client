extends Node

var AutoConnectWebSocket = preload("res://jiber-godot-client/AutoConnectWebSocket.gd")
var Doc = preload("res://jiber-godot-client/Doc.gd")
var _url = "wss://demo.jiber.io"
var _conn
var _doc_dict = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_conn = AutoConnectWebSocket.new(_url)
	_conn.connect("data_received", self, "_on_data")	
	add_child(_conn)
	
	var doc = open('myohmy')
	
	
# Handle incoming messages
func _on_data(str_message):
	var result = JSON.parse(str_message)
	if result.error != OK:
		print(result.error)
		return
		
	var message = result.result
	if !message.doc:
		return
	
	var doc = _doc_dict.get(message.doc)
	if !doc:
		return
		
	doc.on_message(message)
			
			
# open a doc
func open(doc_id):
	var doc = _doc_dict.get(doc_id)
	if !doc:
		doc = Doc.new(doc_id)
		_doc_dict[doc_id] = doc
		doc.connect('close', self, '_on_doc_closed')
	_conn.send(JSON.print({'type': 'open', 'doc': doc_id}))
	return doc
	
	
func _on_doc_closed(doc_id):
	_doc_dict[doc_id] = null
