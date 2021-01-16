tool
class_name MeasuringTape2D, "icons/measuring_tape_2d.svg"
extends Position2D

export(Units.MeasureType2D) var measure = Units.MeasureType2D.LENGTH setget set_measure
export(Units.UnitType) var unit = Units.UnitType.METER setget set_unit
export(int, 0, 10) var decimal_count := 2 setget set_decimal_count
export(Color) var color := Color(0.15, 0.45, 0.5)
export(float) var line_width_pixels := 4.0
# If you are measuring a game world, you may prefer to use pixels per meter.
export(float) var pixels_per_meter = 100 setget set_pixels_per_meter
# If you are measuring UI elements, you may prefer using PPI (DPI).
export(float) var pixels_per_inch = 2.54 setget set_pixels_per_inch

var _editor_viewport: Viewport
var _line: Line2D
var _label: Label
var _sprite: Sprite
onready var _parent = get_parent()


func _ready():
	if not Engine.is_editor_hint():
		queue_free()
		return
	if not _parent is CanvasItem:
		printerr("Failed to create MeasuringTape2D. The parent of a MeasuringTape2D must be CanvasItem-derived.")
		queue_free()
		return
	if _parent is Control:
		set_pixels_per_inch(96)
	_editor_viewport = find_viewport(get_node("/root/EditorNode"), 0)
	# Set up the line.
	_line = Line2D.new()
	_parent.call_deferred("add_child", _line)
	# Set up the Label.
	_label = Label.new()
	_label.rect_min_size = Vector2(400, 30)
	_label.align = Label.ALIGN_CENTER
	_editor_viewport.add_child(_label)


# TODO: This is a really janky way to get the editor viewport.
# Waiting for https://github.com/godotengine/godot-proposals/issues/1302
func find_viewport(node: Node, recursive_level):
	if node.get_class() == "CanvasItemEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result = find_viewport(child, recursive_level)
			if result != null:
				return result


func _process(_delta):
	if not _line or not _label:
		return

	_line.default_color = color
	_line.width = line_width_pixels
	var meters = position / pixels_per_meter
	var abs_meters: Vector2 = meters.abs()
	var amount: float
	if measure == Units.MeasureType.LENGTH:
		_line.points = PoolVector2Array([Vector2.ZERO, position])
		amount = meters.length()
	if measure == Units.MeasureType.AREA or measure == Units.MeasureType.PERIMETER:
		# These vertices generate a square.
		_line.points = PoolVector2Array([Vector2.ZERO, Vector2(position.x, 0),
				position, Vector2(0, position.y), Vector2.ZERO])
		if measure == Units.MeasureType2D.AREA:
			amount = abs_meters.x * abs_meters.y
		else: # measure == Units.MeasureType2D.PERIMETER:
			amount = (abs_meters.x + abs_meters.y) * 2
	var center = _parent.get_global_transform().xform(position / 2)
	_label.text = Units.convert_to_unit_str(amount, unit, measure, decimal_count)
	_label.rect_position = center - (_label.rect_min_size / 2)


func _exit_tree():
	if _line:
		_line.queue_free()
	if _label:
		_label.queue_free()
	if _sprite:
		_sprite.queue_free()


func set_measure(value: int):
	measure = value
	if (unit == Units.UnitType.HECTARE or unit == Units.UnitType.ACRE) and \
			value != Units.MeasureType2D.AREA:
		unit = Units.UnitType.METER
		property_list_changed_notify()


func set_unit(value: int):
	if (value == Units.UnitType.HECTARE or value == Units.UnitType.ACRE) and \
			value != Units.MeasureType2D.AREA:
		measure = Units.MeasureType2D.AREA
		property_list_changed_notify()
	elif value == Units.UnitType.LITER or value == Units.UnitType.GALLON:
		printerr("You can't measure volume in 2D!")
		measure = Units.MeasureType2D.LENGTH
		unit = Units.UnitType.METER
		property_list_changed_notify()
		return
	unit = value


func set_decimal_count(value: int):
	value = int(clamp(value, 0, 10))
	decimal_count = value


func set_pixels_per_meter(value: float):
	pixels_per_meter = value
	pixels_per_inch = value * 0.0254


func set_pixels_per_inch(value: float):
	pixels_per_inch = value
	pixels_per_meter = value / 0.0254
