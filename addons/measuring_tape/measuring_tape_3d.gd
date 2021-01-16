tool
class_name MeasuringTape3D, "icons/measuring_tape_3d.svg"
extends Position3D

export(Units.MeasureType) var measure = Units.MeasureType.LENGTH setget set_measure
export(Units.UnitType) var unit = Units.UnitType.METER setget set_unit
export(int, 0, 10) var decimal_count := 2 setget set_decimal_count

var _editor_camera: Camera
var _editor_viewport: Viewport
var _geometry: ImmediateGeometry
var _label: Label
var _sprite: Sprite3D
onready var _parent = get_parent()


func _ready():
	if not Engine.is_editor_hint():
		queue_free()
		return
	if not _parent is Spatial:
		printerr("Failed to create MeasuringTape3D. The parent of a MeasuringTape3D must be Spatial-derived.")
		queue_free()
		return
	_editor_viewport = find_viewport(get_node("/root/EditorNode"), 0)
	_editor_camera = _editor_viewport.get_child(0)
	# Set up the line.
	_geometry = ImmediateGeometry.new()
	_parent.call_deferred("add_child", _geometry)
	# Set up the Label.
	_label = Label.new()
	_label.rect_min_size = Vector2(400, 30)
	_label.align = Label.ALIGN_CENTER
	_editor_viewport.add_child(_label)


# TODO: This is a really janky way to get the editor viewport.
# Waiting for https://github.com/godotengine/godot-proposals/issues/1302
func find_viewport(node: Node, recursive_level):
	if node.get_class() == "SpatialEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_viewport(child, recursive_level)
			if result != null:
				return result


func _process(_delta):
	if not _geometry or not _label:
		return

	_geometry.clear()
	_geometry.begin(Mesh.PRIMITIVE_LINES)
	_geometry.add_vertex(Vector3.ZERO)
	var end: Vector3
	var abs_position: Vector3 = translation.abs()
	var amount: float
	if measure == Units.MeasureType.LENGTH:
		_geometry.add_vertex(translation)
		amount = translation.length()
	if measure == Units.MeasureType.AREA or measure == Units.MeasureType.PERIMETER:
		var min_axis = abs_position.min_axis()
		# These vertices generate a square.
		if min_axis == Vector3.AXIS_X:
			_geometry.add_vertex(Vector3(0, translation.y, 0))
			_geometry.add_vertex(Vector3(0, translation.y, 0))
			_geometry.add_vertex(Vector3(0, translation.y, translation.z))
			_geometry.add_vertex(Vector3(0, translation.y, translation.z))
			_geometry.add_vertex(Vector3(0, 0, translation.z))
			_geometry.add_vertex(Vector3(0, 0, translation.z))
			_geometry.add_vertex(Vector3(0, 0, 0))
			end = Vector3(0, translation.y, translation.z)
			if measure == Units.MeasureType.AREA:
				amount = abs_position.y * abs_position.z
			else: # measure == Units.MeasureType.PERIMETER:
				amount = (abs_position.y + abs_position.z) * 2
		elif min_axis == Vector3.AXIS_Y:
			_geometry.add_vertex(Vector3(translation.x, 0, 0))
			_geometry.add_vertex(Vector3(translation.x, 0, 0))
			_geometry.add_vertex(Vector3(translation.x, 0, translation.z))
			_geometry.add_vertex(Vector3(translation.x, 0, translation.z))
			_geometry.add_vertex(Vector3(0, 0, translation.z))
			_geometry.add_vertex(Vector3(0, 0, translation.z))
			_geometry.add_vertex(Vector3(0, 0, 0))
			end = Vector3(translation.x, 0, translation.z)
			if measure == Units.MeasureType.AREA:
				amount = abs_position.x * abs_position.z
			else: # measure == Units.MeasureType.PERIMETER:
				amount = (abs_position.x + abs_position.z) * 2
		else: # min_axis == Vector3.AXIS_Z:
			_geometry.add_vertex(Vector3(translation.x, 0, 0))
			_geometry.add_vertex(Vector3(translation.x, 0, 0))
			_geometry.add_vertex(Vector3(translation.x, translation.y, 0))
			_geometry.add_vertex(Vector3(translation.x, translation.y, 0))
			_geometry.add_vertex(Vector3(0, translation.y, 0))
			_geometry.add_vertex(Vector3(0, translation.y, 0))
			_geometry.add_vertex(Vector3(0, 0, 0))
			end = Vector3(translation.x, translation.y, 0)
			if measure == Units.MeasureType.AREA:
				amount = abs_position.x * abs_position.y
			else: # measure == Units.MeasureType.PERIMETER:
				amount = (abs_position.x + abs_position.y) * 2
	else:
		end = translation
	if measure == Units.MeasureType.VOLUME or measure == Units.MeasureType.SURFACE_AREA:
		# These vertices generate a cube.
		_geometry.add_vertex(Vector3(translation.x, 0, 0))
		_geometry.add_vertex(Vector3(translation.x, 0, 0))
		_geometry.add_vertex(Vector3(translation.x, translation.y, 0))
		_geometry.add_vertex(Vector3(translation.x, translation.y, 0))
		_geometry.add_vertex(translation)
		_geometry.add_vertex(translation)
		_geometry.add_vertex(Vector3(0, translation.y, translation.z))
		_geometry.add_vertex(Vector3(0, translation.y, translation.z))
		_geometry.add_vertex(Vector3(0, 0, translation.z))
		_geometry.add_vertex(Vector3(0, 0, translation.z))
		_geometry.add_vertex(Vector3(translation.x, 0, translation.z))
		_geometry.add_vertex(Vector3(translation.x, 0, translation.z))
		_geometry.add_vertex(translation)
		_geometry.add_vertex(Vector3(0, 0, 0))
		_geometry.add_vertex(Vector3(0, 0, translation.z))
		_geometry.add_vertex(Vector3(0, translation.y, translation.z))
		_geometry.add_vertex(Vector3(0, translation.y, 0))
		_geometry.add_vertex(Vector3(0, translation.y, 0))
		_geometry.add_vertex(Vector3(translation.x, translation.y, 0))
		_geometry.add_vertex(Vector3(0, 0, 0))
		_geometry.add_vertex(Vector3(0, translation.y, 0))
		_geometry.add_vertex(Vector3(translation.x, 0, 0))
		_geometry.add_vertex(Vector3(translation.x, 0, translation.z))
		if measure == Units.MeasureType.VOLUME:
			amount = abs_position.x * abs_position.y * abs_position.z
		else:
			amount = (abs_position.x * abs_position.y +
					abs_position.x * abs_position.z +
					abs_position.y * abs_position.z) * 2
	_geometry.end()
	var center = _parent.global_transform.xform(end / 2)
	_label.text = Units.convert_to_unit_str(amount, unit, measure, decimal_count)
	_label.visible = not _editor_camera.is_position_behind(center)
	_label.rect_position = _editor_camera.unproject_position(center)
	_label.rect_position -= (_label.rect_min_size / 2)


func _exit_tree():
	if _geometry:
		_geometry.queue_free()
	if _label:
		_label.queue_free()
	if _sprite:
		_sprite.queue_free()


func set_measure(value: int):
	measure = value
	if (unit == Units.UnitType.HECTARE or unit == Units.UnitType.ACRE) and \
			value != Units.MeasureType.AREA and value != Units.MeasureType.SURFACE_AREA:
		unit = Units.UnitType.METER
		property_list_changed_notify()
	elif (unit == Units.UnitType.LITER or unit == Units.UnitType.GALLON) and \
			value != Units.MeasureType.VOLUME:
		unit = Units.UnitType.METER
		property_list_changed_notify()


func set_unit(value: int):
	unit = value
	if (value == Units.UnitType.HECTARE or value == Units.UnitType.ACRE) and \
			measure != Units.MeasureType.AREA and measure != Units.MeasureType.SURFACE_AREA:
		measure = Units.MeasureType.AREA
		property_list_changed_notify()
	elif (value == Units.UnitType.LITER or value == Units.UnitType.GALLON) and \
			measure != Units.MeasureType.VOLUME:
		measure = Units.MeasureType.VOLUME
		property_list_changed_notify()


func set_decimal_count(value: int):
	value = int(clamp(value, 0, 10))
	decimal_count = value
