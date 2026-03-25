class_name Pathfinding
extends Node3D

@export var grid:Grid
@export var path_request_manager:PathRequestManager

func start_find_path(start_pos:Vector3, end_pos:Vector3) -> void:
	FindPath(start_pos, end_pos)

func FindPath(startPos:Vector3, endPos:Vector3) -> void:
	var waypoints:Array[Vector3] = []
	var path_success:bool = false
	
	var startNode:GridNode = grid.GetNodeFromPosition(startPos)
	var endNode:GridNode = grid.GetNodeFromPosition(endPos)

	if !startNode.walkable or !endNode.walkable:
		return

	var openSet = MinHeap.new()
	var closedSet:= {}

	openSet.Add(startNode)

	while openSet.Size() > 0:
		var currentNode:GridNode = openSet.Pop()
		closedSet[currentNode] = true

		if currentNode == endNode:
			path_success = true
			break

		for neighbour:GridNode in grid.GetNeighbours(currentNode):
			if (!neighbour.walkable || closedSet.has(neighbour)):
				continue
			
			var inOpenSet = openSet.Contains(neighbour)
			var newMovementCostToNeighbour:int = currentNode.gCost + GetDistance(currentNode, neighbour) + neighbour.terrain_cost
			if (newMovementCostToNeighbour < neighbour.gCost || !inOpenSet):
				neighbour.gCost = newMovementCostToNeighbour
				neighbour.hCost = GetDistance(neighbour, endNode)
				neighbour.parent = currentNode

				if !inOpenSet:
					openSet.Add(neighbour)
				else:
					openSet.UpdateItem(neighbour)
	
	await get_tree().process_frame
	if path_success:
		waypoints = RetracePath(startNode, endNode)
	path_request_manager.finished_processing(waypoints, path_success)

func GetDistance(nodeA:GridNode, nodeB:GridNode) -> int:
	var dstX:int = abs(nodeA.gridX - nodeB.gridX)
	var dstY:int = abs(nodeA.gridY - nodeB.gridY)

	if dstX > dstY:
		return 14 * dstY + 10 * (dstX-dstY)
	else:
		return 14 * dstX + 10 * (dstY-dstX)

func RetracePath(startNode:GridNode, endNode:GridNode) -> Array[Vector3]:
	var path:Array[GridNode]
	var currentNode = endNode

	while currentNode != startNode:
		path.append(currentNode)
		currentNode = currentNode.parent
		print(currentNode.terrain_cost)

	var waypoints:Array[Vector3] = simplify_path(path)
	waypoints.reverse()

	return waypoints

func simplify_path(path:Array[GridNode]) -> Array[Vector3]:
	var waypoints:Array[Vector3]
	var old_direction:Vector2 = Vector2.ZERO

	for i in range(1, path.size()):
		var new_direction:Vector2 = Vector2(path[i-1].gridX - path[i].gridX, path[i-1].gridY - path[i].gridY)

		if new_direction != old_direction:
			waypoints.append(path[i].worldPosition)
		
		old_direction = new_direction
	
	return waypoints
