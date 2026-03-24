class_name GridNode

var walkable:bool
var worldPosition:Vector3

var gridX:int
var gridY:int

var parent:GridNode

var gCost:int
var hCost:int
var fCost:int:
	get():
		return hCost + gCost
var heapIndex:int:
	get():
		return heapIndex
	set(x):
		heapIndex = x

func _init(_walkable:bool, _worldPosition:Vector3, _x:int, _y:int):
	walkable = _walkable
	worldPosition = _worldPosition

	gridX = _x
	gridY = _y

func CompareTo(node:GridNode) -> int:
	var compare:int = -1 if (fCost < node.fCost) else 0 if (fCost == node.fCost) else 1
	if fCost == 0:
		compare = -1 if (hCost < node.hCost) else 0 if (hCost == node.hCost) else 1
	return compare