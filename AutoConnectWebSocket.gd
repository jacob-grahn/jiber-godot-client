extends Node

# The one signal this class emits
signal data_received(message)

# The URL we will connect to
var _url

# Our WebSocketClient instance
var _client

# Keep track of how many times the connection has failed
var _fail_count = 0

# The last time a client tried to connect
var _last_try_time

# A list of messages waiting to be sent
var _write_buffer = []


# Constructor
func _init(url):
	_url = url
	
	
# 
func _ready():
	_create_client()


# Create a client and connect to url
func _create_client():
	# if there is an existing client, make sure it is cleared out
	_destroy_client()
	
	# set up a new client
	_client = WebSocketClient.new()
	_client.connect("connection_closed", self, "_on_closed")
	_client.connect("connection_error", self, "_on_closed")
	_client.connect("connection_established", self, "_on_connected")
	_client.connect("data_received", self, "_on_data")
	
	# Initiate connection to the given URL.
	_last_try_time = OS.get_unix_time()
	var result = _client.connect_to_url(_url)
	if result != OK:
		print("Unable to connect to ", _url)
		_fail_count += 1
		_destroy_client()


# Clean up and remove an old client	
func _destroy_client():
	if (_client):
		_client.disconnect("connection_closed", self, "_on_closed")
		_client.disconnect("connection_error", self, "_on_closed")
		_client.disconnect("connection_established", self, "_on_connected")
		_client.disconnect("data_received", self, "_on_data")
		_client.disconnect_from_host()
		_client = null
	

# Destroy the client if it disconnects
func _on_closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	_destroy_client()


# Send any pending messages to the server
func _on_connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	
	# reset the fail count
	_fail_count = 0
	
	# send the write buffer
	for message in _write_buffer:
		_client.get_peer(1).put_packet(message.to_utf8())


# Handle messages received from server
func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var str_message = _client.get_peer(1).get_packet().get_string_from_utf8()
	emit_signal("data_received", str_message)


# Check the client on the regular, reconnect if it has gone away
func _process(_delta):
	if (_client):
		# Call this in _process or _physics_process. Data transfer, and signals
		# emission will only happen when calling this function.
		_client.poll()
	else:
		var elapsed = OS.get_unix_time() - _last_try_time
		if (elapsed > 1 + _fail_count):
			_create_client()


# Send a message to the server
func send(string):
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	if (_client):
		_client.get_peer(1).put_packet(string.to_utf8())
	else:
		_write_buffer.push(string)
