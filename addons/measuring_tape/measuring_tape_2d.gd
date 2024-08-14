@tool
@icon("icons/measuring_tape_2d.svg")
class_name MeasuringTape2D extends Marker2D

@export var measure = Units.MeasureType2D.LENGTH: set = set_measure
@export var unit = Units.UnitType.METER: set = set_unit
@export var decimal_count := 2: set = set_decimal_count
@export var color := Color(0.15, 0.45, 0.5)
@export var line_width_pixels := 4.0
# If you are measuring a game world, you may prefer to use pixels per meter.
@export var pixels_per_meter: float = 100: set = set_pixels_per_meter
# If you are measuring UI elements, you may prefer using PPI (DPI).
@export var pixels_per_inch: float = 2.54: set = set_pixels_per_inch

var _editor_viewport: SubViewport
var _line: Line2D
var _label: Label
var _sprite: Sprite2D
@onready var _parent = get_parent()


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
	_editor_viewport = EditorInterface.get_editor_viewport_2d()
	# Set up the line.
	_line = Line2D.new()
	_parent.call_deferred("add_child", _line)
	# Set up the Label.
	_label = Label.new()
	_label.custom_minimum_size = Vector2(400, 30)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_editor_viewport.add_child(_label)


func _process(_delta):
	if not _line or not _label:
		return

	_line.default_color = color
	_line.width = line_width_pixels
	var meters = position / pixels_per_meter
	var abs_meters: Vector2 = meters.abs()
	var amount: float
	if measure == Units.MeasureType.LENGTH:
		_line.points = PackedVector2Array([Vector2.ZERO, position])
		amount = meters.length()
	if measure == Units.MeasureType.AREA or measure == Units.MeasureType.PERIMETER:
		# These vertices generate a square.
		_line.points = PackedVector2Array([Vector2.ZERO, Vector2(position.x, 0),
				position, Vector2(0, position.y), Vector2.ZERO])
		if measure == Units.MeasureType2D.AREA:
			amount = abs_meters.x * abs_meters.y
		else: # measure == Units.MeasureType2D.PERIMETER:
			amount = (abs_meters.x + abs_meters.y) * 2
	var center = _parent.get_global_transform() * (position / 2)
	_label.text = Units.convert_to_unit_str(amount, unit, measure, decimal_count)
	_label.position = center - (_label.custom_minimum_size / 2)


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
		notify_property_list_changed()


func set_unit(value: int):
	if (value == Units.UnitType.HECTARE or value == Units.UnitType.ACRE) and \
			value != Units.MeasureType2D.AREA:
		measure = Units.MeasureType2D.AREA
		notify_property_list_changed()
	elif value == Units.UnitType.LITER or value == Units.UnitType.GALLON:
		printerr("You can't measure volume in 2D!")
		measure = Units.MeasureType2D.LENGTH
		unit = Units.UnitType.METER
		notify_property_list_changed()
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
