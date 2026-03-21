class_name PathRequestManager
extends Node3D

var path_request_queue:Queue = Queue.new()
var current_path_request:PathRequest
var is_processing_path:bool

@export var pathfinding:Pathfinding

func request_path(path_start:Vector3, path_end:Vector3, callback:Callable):
	var new_request = PathRequest.new(path_start, path_end, callback)
	path_request_queue.enqueue(new_request)
	try_next_process()

func try_next_process() -> void:
	if !is_processing_path and path_request_queue.size() > 0:
		current_path_request = path_request_queue.dequeue()
		is_processing_path = true
		pathfinding.start_find_path(current_path_request.path_start, current_path_request.path_end)

func finished_processing(path:Array[Vector3], success:bool) -> void:
	current_path_request.callback.call(path, success)
	is_processing_path = false
	try_next_process()

class PathRequest:
	var path_start:Vector3
	var path_end:Vector3
	var callback:Callable

	func _init(_path_start:Vector3, _path_end:Vector3, _callback:Callable):
		path_start = _path_start
		path_end = _path_end
		callback = _callback
		
