extends Node3D
class_name Grid

@export var startNode:Node3D
@export var endNode:Node3D
@export var walkableNode:StaticBody3D
@export var unwalkableMask: int

# unwalkable is layer/mask 2
var gridWorldSize:Vector2
@export var nodeRadius:float
var gridNodeDict:Dictionary[Vector2i, GridNode]



var nodeDiameter:float
var gridSizeX:int
var gridSizeY:int

func _ready() -> void:
	gridWorldSize = Vector2(walkableNode.scale.x * 2, walkableNode.scale.z * 2)

	nodeDiameter = nodeRadius * 2
	gridSizeX = roundi(gridWorldSize.x / nodeDiameter)
	gridSizeY = roundi(gridWorldSize.y / nodeDiameter)
	CreateGrid()

func CreateGrid() -> void:
	var worldTopLeft:Vector3 = position - Vector3.RIGHT * gridWorldSize.x/2 - Vector3.FORWARD * gridWorldSize.y/2

	for x in range(gridSizeX):
		for y in range(gridSizeY):
			var worldPoint:Vector3 = worldTopLeft +  Vector3.RIGHT * (x * nodeDiameter + nodeRadius) + Vector3.FORWARD * (y * nodeDiameter + nodeRadius)

			var walkable:bool = CheckWalkabilityInLocation(worldPoint, nodeRadius)

			gridNodeDict[Vector2i(x,y)] = GridNode.new(walkable, worldPoint, x, y)

func CheckWalkabilityInLocation(position: Vector3, radius: float) -> bool:
	var sphere = SphereShape3D.new()
	sphere.radius = radius*0.8

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform.origin = position
	query.collision_mask = unwalkableMask

	var result = get_world_3d().direct_space_state.intersect_shape(query)

	return result.size() == 0

func GetNodeFromPosition(position: Vector3) -> GridNode:
	var percentX:float = (position.x + gridWorldSize.x/2)/gridWorldSize.x
	var percentY:float = (position.z + gridWorldSize.y/2)/gridWorldSize.y
	percentX = clampf(percentX, 0, 1)
	percentY = clampf(percentY, 0, 1)
	percentY = abs(percentY-1)

	var x:int = roundi((gridSizeX-1) * percentX)
	var y:int = roundi((gridSizeY-1) * percentY)
	return gridNodeDict[Vector2i(x,y)]

func GetNeighbours(node:GridNode) -> Array[GridNode]:
	var neighbours:Array[GridNode]

	for x in range(-1, 2):
		for y in range(-1, 2):

			if (x == 0 && y == 0):
				continue

			var checkX:int = node.gridX + x
			var checkY:int = node.gridY + y

			if (checkX >= 0 && checkX < gridSizeX && checkY >= 0 && checkY < gridSizeY):
				neighbours.append(gridNodeDict[Vector2i(checkX, checkY)])
	return neighbours

var path:Array[GridNode]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gridNodeDict == null:
		for cell in gridNodeDict:
			var node = gridNodeDict[cell]

			var color = Color.GREEN if node.walkable else Color.RED

			DebugDraw.draw_rect_3d(node.worldPosition, nodeDiameter*0.9, color) # Draw debug rect

	if startNode != null:
		var start:GridNode = GetNodeFromPosition(startNode.position)
		var color = Color.AQUA

		DebugDraw.draw_rect_3d(start.worldPosition, nodeDiameter*0.92, color) # Draw debug rect

	if endNode != null:
		var end:GridNode = GetNodeFromPosition(endNode.position)
		var color = Color.YELLOW

		DebugDraw.draw_rect_3d(end.worldPosition, nodeDiameter*0.92, color) # Draw debug rect

	if path != null:
		for n in range(path.size()):
			var node = path[n]
			var color = Color.WHITE
			DebugDraw.draw_rect_3d(node.worldPosition, nodeDiameter*0.90, color)
		
	
