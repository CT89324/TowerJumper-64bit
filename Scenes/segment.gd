extends Node3D


func set_material(material: Material) -> void:
	get_node("REGULAR").material_override = material
	get_node("REGULAR/Cover").material_override = material


func set_bad() -> void:
	get_node("REGULAR/StaticBody").add_to_group("bad")


func explode() -> void:
	var a = get_node_or_null("REGULAR/StaticBody")
	if a != null:
		a.queue_free()
	a = get_node_or_null("REGULAR/AnimationPlayer")
	if a != null:
		a.play("explode")


func meteorize() -> void:
	var a = get_node_or_null("REGULAR/StaticBody")
	if a != null:
		a.queue_free()
	var mat := StandardMaterial3D.new()
	mat.roughness = 1.0
	mat.metallic_specular = 0.0
	mat.albedo_color = get_tree().get_nodes_in_group("player")[0].color
	get_node("REGULAR").material_override = mat
	get_node("REGULAR/Cover").material_override = mat
