class_name Units
extends Resource

enum MeasureType {
	LENGTH = 0,
	AREA = 1,
	PERIMETER = 2,
	VOLUME = 3,
	SURFACE_AREA = 4,
}

enum MeasureType2D {
	LENGTH = 0,
	AREA = 1,
	PERIMETER = 2,
}

enum UnitType {
	METER = 0,
	MILLIMETER = 1,
	CENTIMETER = 2,
	KILOMETER = 3,
	HAMMER = 4, # The Source engine's units.
	INCH = 5,
	FOOT = 6,
	FOOT_AND_INCH = 7,
	YARD = 8,
	MILE = 9,
	LIGHT_SECOND = 10,
	LIGHT_NANOSECOND = 11,
	HECTARE = 12,
	ACRE = 13,
	LITER = 14,
	GALLON = 15,
}

const names = [
	"meters",
	"millimeters",
	"centimeters",
	"kilometers",
	"Hammer units", # The Source engine's units.
	"inches",
	"feet",
	"feet", # Special case, just repeat the value for foot.
	"yards",
	"miles",
	"light seconds",
	"light nanoseconds",
	"hectares",
	"acres",
	"liters",
	"gallons",
]

# X meters in a ___, or 1 ___ is x meters.
const conversion_factors = [
	1.0, # Meter.
	0.001, # Millimeter.
	0.01, # Centimeter.
	1000.0, # Kilometer.
	0.01905, # Hammer unit, the Source engine's units.
	0.0254, # Inch.
	0.3048, # Foot.
	0.3048, # Foot and inch (special case, just repeat the value for foot).
	0.9144, # Yard.
	1609.344, # Mile.
	299792458.0, # Light second.
	0.299792458, # Light nanosecond.
	10000, # Hectares (in terms of square meters).
	4046.8564224, # Acres (in terms of square meters).
	0.001, # Liters (in terms of cubic meters).
	0.003785411784, # Gallons (in terms of cubic meters).
]

static func convert_to_unit_str(amount, unit = UnitType.METER, measure = MeasureType.LENGTH, decimal_count = 2):
	var separator = " "
	var factor = conversion_factors[unit]
	# Only run the conversion to square/cubic for units of length (unit < 12).
	if unit < 12:
		if measure == MeasureType.AREA or measure == MeasureType.SURFACE_AREA:
			separator = " square "
			factor *= factor
		elif measure == MeasureType.VOLUME:
			separator = " cubic "
			factor *= factor * factor

	# Special case for feet and inches (specifically FOOT_AND_INCH).
	if unit == UnitType.FOOT_AND_INCH:
		var feet = amount / factor
		var feet_floored = int(feet)
		var inches_base = (feet - feet_floored) * factor
		var inch_text = convert_to_unit_str(inches_base, UnitType.INCH, measure, decimal_count)
		return str(feet_floored) + separator + names[unit] + " and " + inch_text

	# The rest of the code for all other units (not FOOT_AND_INCH).
	var format_string = "%." + str(decimal_count) + "f"
	return (format_string % (amount / factor)) + separator + names[unit]
