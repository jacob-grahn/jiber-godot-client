static func apply(state, action):
	var type = action.type
	var path = action.path.split('.')
	var new_value = action.value
	
	if type == 'SET':
		_setp(state, path, new_value)
	if type == 'DELETE':
		_setp(state, path, null)
	if type == 'ADD':
		_setp(state, path, _getp(state, path) + new_value)
	if type == 'PUSH':
		var arr = _getp(state, path)
		arr.push(new_value)
	if type == 'SPLICE':
		# todo: this is pretty wrong
		var arr = _getp(state, path)
		var start = action.start
		var count = action.count
		var items = action.items
		var new_arr = arr.slice(start, start + count)
		_setp(state, path, new_arr)
	return state
		
static func _setp(state, path, new_value):
	var path_len = path.size()
	for i in range(path_len):
		var key = path[i]
		if i != path_len:
			state = state[key]
		else:
			state[key] = new_value
	
static func _getp(state, path):
	var path_len = path.size()
	for i in range(path_len):
		var key = path[i]
		if i != path_len:
			state = state[key]
		else:
			return state[key]
