extends Node3D

var meshes := []

func _process(delta):
	# Clear previous frame's debug meshes
	for m in meshes:
		if is_instance_valid(m):
			m.queue_free()
	meshes.clear()


func draw_rect_3d(position: Vector3, size: float, color: Color):
	var mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)

	var box = BoxMesh.new()
	box.size = Vector3(size, 0.01, size)
	mesh_instance.mesh = box

	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = 0.1
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true # always visible

	mesh_instance.material_override = mat
	mesh_instance.global_position = position

	meshes.append(mesh_instance)

func draw_line_custom(start: Vector3, end: Vector3, color: Color):
	var steps = 5
	for i in range(steps):
		var t = float(i) / steps
		var p = start.lerp(end, t)
		draw_rect_3d(p, 0.1, color)
