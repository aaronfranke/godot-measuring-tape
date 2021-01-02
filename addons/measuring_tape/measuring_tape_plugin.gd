tool
extends EditorPlugin


func _enter_tree():
	name = "MeasuringTapeEditorPlugin"
	add_custom_type("MeasuringTape2D", "Position2D", preload("measuring_tape_2d.gd"), preload("icons/measuring_tape_2d.svg"))
	add_custom_type("MeasuringTape3D", "Position3D", preload("measuring_tape_3d.gd"), preload("icons/measuring_tape_3d.svg"))


func _exit_tree():
	remove_custom_type("MeasuringTape2D")
	remove_custom_type("MeasuringTape3D")
