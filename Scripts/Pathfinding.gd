extends Node3D
@export var grid:Grid

func _init():
	pass

func _process(delta):
	FindPath(grid.startNode.position, grid.endNode.position)

func FindPath(startPos:Vector3, endPos:Vector3) -> void:
	var startNode:GridNode = grid.GetNodeFromPosition(startPos)
	var endNode:GridNode = grid.GetNodeFromPosition(endPos)

	var openSet:Array[GridNode]
	var closedSet:Dictionary[int, GridNode]
	var closedSetCount:int = 0

	openSet.append(startNode)

	while openSet.size() > 0:
		var currentNode:GridNode = openSet[0]
		for i in range(1, openSet.size()):
			if (openSet[i].fCost < currentNode.fCost || openSet[i].fCost == currentNode.fCost && openSet[i].hCost < currentNode.hCost):
				currentNode = openSet[i]

		
		openSet.erase(currentNode)
		closedSet[closedSetCount] = currentNode
		closedSetCount = closedSetCount+1

		if currentNode == endNode:
			print("end reached!")
			RetracePath(startNode, endNode)
			return

		for neighbour:GridNode in grid.GetNeighbours(currentNode):
			if (!neighbour.walkable || closedSet.values().has(neighbour)):
				continue
			
			var newMovementCostToNeighbour:int = currentNode.gCost + GetDistance(currentNode, neighbour)
			if (newMovementCostToNeighbour < neighbour.gCost || !openSet.has(neighbour)):
				neighbour.gCost = newMovementCostToNeighbour
				neighbour.hCost = GetDistance(neighbour, endNode)
				neighbour.parent = currentNode

				if !openSet.has(neighbour):
					openSet.append(neighbour)
		


func GetDistance(nodeA:GridNode, nodeB:GridNode) -> int:
	var dstX:int = abs(nodeA.gridX - nodeB.gridX)
	var dstY:int = abs(nodeA.gridY - nodeB.gridY)

	if dstX > dstY:
		return 14 * dstY + 10 * (dstX-dstY)
	else:
		return 14 * dstX + 10 * (dstY-dstX)

func RetracePath(startNode:GridNode, endNode:GridNode) -> void:
	var path:Array[GridNode]
	var currentNode = endNode

	while currentNode != startNode:
		path.append(currentNode)
		currentNode = currentNode.parent

	path.reverse()

	grid.path = path
