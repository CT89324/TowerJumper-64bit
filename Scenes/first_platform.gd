extends "res://abstract_platform.gd"


func _ready() -> void:
	for i in range(0, 14):
		var aux = segment.instantiate()
		aux.set_material(global.mat_regular)

		aux.rotate_y(deg_to_rad(offset * i))
		children.add_child(aux)


func _on_Area_body_enter(body) -> void:
	delete_enter(body)
