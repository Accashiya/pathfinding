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

func _init(_walkable:bool, _worldPosition:Vector3, _x:int, _y:int):
	walkable = _walkable
	worldPosition = _worldPosition

	gridX = _x
	gridY = _y

	