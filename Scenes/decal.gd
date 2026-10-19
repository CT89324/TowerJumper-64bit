extends MeshInstance3D

@onready var color: Color = get_tree().get_nodes_in_group("player")[0].color


func _ready() -> void:
	var mat: StandardMaterial3D = material_override.duplicate()
	material_override = mat
	mat.albedo_color = color


func _on_OpacityTimer_timeout() -> void:
	if color.a <= 0:
		queue_free()
	color.a -= 0.001
	(material_override as StandardMaterial3D).albedo_color = color
