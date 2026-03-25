extends Node3D
class_name Grid

######### For Debugging #############
@export_group("Debugging")
@export var startNode:Node3D
@export var endNode:Node3D
@export var display_debug_stuff:bool
#####################################

####### Grid Properties ############
@export_group("Grid Properties")
@export var walkableNode:StaticBody3D
## Mask number in editor
@export_range(1,32) var unwalkableMask: int
@export var nodeRadius:float

var gridWorldSize:Vector2
var gridNodeDict:Dictionary[Vector2i, GridNode]

var nodeDiameter:float
var gridSizeX:int
var gridSizeY:int
##################################

###### Movement Weighting ##########
@export_group("Weights")
@export var walkable_regions:Array[TerrainType]
var walkable_mask:int
var walkable_regions_dict:Dictionary[int, int]

@export_range(0,3) var blur_size:int = 1
@export var unwalkable_terrain_cost:int = 100
################################

func _ready() -> void:
	gridWorldSize = Vector2(walkableNode.scale.x * 2, walkableNode.scale.z * 2)

	nodeDiameter = nodeRadius * 2
	gridSizeX = roundi(gridWorldSize.x / nodeDiameter)
	gridSizeY = roundi(gridWorldSize.y / nodeDiameter)

	for terrain in walkable_regions:
		var terrain_layer_bitwise:int = 1<<(terrain.t_layer-1)

		walkable_mask |= terrain_layer_bitwise
		walkable_regions_dict[terrain_layer_bitwise] = terrain.t_cost

	CreateGrid()

func CreateGrid() -> void:
	var worldTopLeft:Vector3 = position - Vector3.RIGHT * gridWorldSize.x/2 - Vector3.FORWARD * gridWorldSize.y/2

	for x in range(gridSizeX):
		for y in range(gridSizeY):
			var worldPoint:Vector3 = worldTopLeft +  Vector3.RIGHT * (x * nodeDiameter + nodeRadius) + Vector3.FORWARD * (y * nodeDiameter + nodeRadius)

			var walkable:bool = CheckWalkabilityInLocation(worldPoint, nodeRadius)
			var terrain_penalty:int = 0

		
			terrain_penalty = check_terrain_penalty(worldPoint)

			if !walkable:
				terrain_penalty += unwalkable_terrain_cost

			gridNodeDict[Vector2i(x,y)] = GridNode.new(walkable, worldPoint, x, y, terrain_penalty)

	blur_penalty_map(blur_size)

func CheckWalkabilityInLocation(position: Vector3, radius: float) -> bool:
	var sphere = SphereShape3D.new()
	sphere.radius = radius*0.8

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform.origin = position
	query.collision_mask = unwalkableMask

	var result = get_world_3d().direct_space_state.intersect_shape(query)

	return result.size() == 0

func check_terrain_penalty(position:Vector3) -> int:
	var query = PhysicsRayQueryParameters3D.create(position + Vector3.UP * 50, position)
	query.collision_mask = walkable_mask
	query.exclude = [self]
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result && result.collider is CollisionObject3D:
		return walkable_regions_dict[result.collider.collision_layer]

	return 0

func blur_penalty_map(blur_size:int) -> void:
	var kernel_size:int = blur_size * 2 + 1
	
	var horizontal_penalties:Dictionary[Vector2i,int]
	var vertical_penalties:Dictionary[Vector2i,int]

	for y in range(0, gridSizeY):
		horizontal_penalties[Vector2i(0,y)] = 0
		for x in range(-blur_size, blur_size+1):
			var sample_x:int = clamp(x, 0, blur_size)
			horizontal_penalties[Vector2i(0,y)] += gridNodeDict[Vector2i(sample_x,y)].terrain_cost
		
		for x in range(1, gridSizeX):
			var remove_index:int = clamp(x - blur_size - 1, 0, gridSizeX)
			var add_index:int = clamp(x + blur_size, 0, gridSizeX-1)

			horizontal_penalties[Vector2i(x,y)] = horizontal_penalties[Vector2i(x-1,y)] - gridNodeDict[Vector2i(remove_index,y)].terrain_cost + gridNodeDict[Vector2i(add_index,y)].terrain_cost

	for x in range(0, gridSizeX):
		vertical_penalties[Vector2i(x,0)] = 0
		for y in range(-blur_size, blur_size+1):
			var sample_y:int = clamp(y, 0, blur_size)
			vertical_penalties[Vector2i(x,0)] += horizontal_penalties[Vector2i(x,sample_y)]
		
		var blurred_penalty:int = roundi(float(vertical_penalties[Vector2i(x,0)]) / kernel_size * kernel_size)
		gridNodeDict[Vector2i(x,0)].terrain_cost = blurred_penalty

		for y in range(1, gridSizeY):
			var remove_index:int = clamp(y - blur_size - 1, 0, gridSizeY)
			var add_index:int = clamp(y + blur_size, 0, gridSizeY-1)
			vertical_penalties[Vector2i(x,y)] = vertical_penalties[Vector2i(x,y-1)] - horizontal_penalties[Vector2i(x,remove_index)] + horizontal_penalties[Vector2i(x,add_index)]
			blurred_penalty = roundi(float(vertical_penalties[Vector2i(x,y)]) / kernel_size * kernel_size)
			gridNodeDict[Vector2i(x,y)].terrain_cost = blurred_penalty

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if display_debug_stuff:
		if gridNodeDict != null:
			for cell in gridNodeDict:
				var node = gridNodeDict[cell]

				var color = Color.GREEN if node.walkable else Color.RED

				DebugDraw.draw_rect_3d(node.worldPosition, nodeDiameter*0.9, color) # Draw debug rect

		if startNode != null:
			var start:GridNode = GetNodeFromPosition(startNode.position)
			var color = Color.AQUA

			DebugDraw.draw_rect_3d(start.worldPosition, nodeDiameter*0.95, color) # Draw debug rect

		if endNode != null:
			var end:GridNode = GetNodeFromPosition(endNode.position)
			var color = Color.YELLOW

			DebugDraw.draw_rect_3d(end.worldPosition, nodeDiameter*0.95, color) # Draw debug rect
