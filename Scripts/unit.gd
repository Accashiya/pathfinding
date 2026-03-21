extends Node3D

@export var target:Node3D
var speed:float = 5
var path:Array[Vector3]
var targetIndex:int

@export var path_request_manager:PathRequestManager
@export var pathfinding:Pathfinding

@export var display_debug_stuff:bool

var following_path:bool = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		path_request_manager.request_path(position, target.position, on_path_found)

func _physics_process(delta: float) -> void:
	if following_path:
		follow_path(delta)

func on_path_found(new_path:Array[Vector3], path_successful:bool) -> void:
	if path_successful:
		path = new_path
		following_path = true

func follow_path(delta: float) -> void:
	if targetIndex >= path.size():
		following_path = false
		return
	var currentWaypoint:Vector3 = path[targetIndex]

	position = position.move_toward(currentWaypoint, speed * delta)
	if position.distance_to(currentWaypoint) < 0.1:
		targetIndex += 1

func _process(delta):
	if display_debug_stuff:
		if path != null:
			for i in range(targetIndex, path.size()):
				var color = Color.BLACK

				DebugDraw.draw_rect_3d(path[i], 0.5, color)
			
			for i in range(targetIndex, path.size()):
				var color = Color.ORANGE
				DebugDraw.draw_line_custom(position, path[targetIndex], color)
